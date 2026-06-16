import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { Sale } from './entities/sale.entity';
import { SaleItem } from './entities/sale-item.entity';
import { Payment } from './entities/payment.entity';
import { InvoiceSequence } from './entities/invoice-sequence.entity';
import { Product } from '../products/entities/product.entity';
import { Customer } from '../customers/entities/customer.entity';
import { InventoryLog, InventoryActionType } from '../inventory/entities/inventory-log.entity';

export class CartItemDto {
  productId: string;
  quantity: number;
  unitPrice: number;
  taxPercentage: number;
}

export class CheckoutDto {
  customerId?: string;
  items: CartItemDto[];
  totalAmount: number;
  discountAmount: number;
  taxAmount: number;
  netAmount: number;
  payments: {
    amount: number;
    paymentMethod: string; // cash, upi, card, bank_transfer, credit
  }[];
}

@Injectable()
export class SalesService {
  constructor(
    @InjectRepository(Sale)
    private readonly saleRepository: Repository<Sale>,
    private readonly dataSource: DataSource,
  ) {}

  private getFinancialYear(): string {
    const today = new Date();
    const month = today.getMonth(); // 0-11
    const year = today.getFullYear();
    // Indian Financial Year: April to March
    if (month >= 3) {
      return `${year}-${(year + 1).toString().slice(-2)}`;
    } else {
      return `${year - 1}-${year.toString().slice(-2)}`;
    }
  }

  async checkout(shopId: string, checkoutDto: CheckoutDto, user: any): Promise<Sale> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // 1. Generate Invoice Number safely
      const financialYear = this.getFinancialYear();
      
      let sequence = await queryRunner.manager.findOne(InvoiceSequence, {
        where: { shopId, financialYear },
        lock: { mode: 'pessimistic_write' },
      });

      if (!sequence) {
        sequence = queryRunner.manager.create(InvoiceSequence, {
          shopId,
          financialYear,
          currentNumber: 0,
        });
        await queryRunner.manager.save(sequence);
      }

      sequence.currentNumber += 1;
      await queryRunner.manager.save(sequence);

      const invoiceNumber = `INV-${financialYear}-${sequence.currentNumber.toString().padStart(6, '0')}`;

      // 2. Calculate Amount Paid and Due
      const amountPaid = checkoutDto.payments.reduce((sum, p) => sum + p.amount, 0);
      const amountDue = checkoutDto.netAmount - amountPaid;

      // 3. Create Sale Record
      const sale = queryRunner.manager.create(Sale, {
        shopId,
        customerId: checkoutDto.customerId,
        invoiceNumber,
        status: 'completed',
        totalAmount: checkoutDto.totalAmount,
        discountAmount: checkoutDto.discountAmount,
        taxAmount: checkoutDto.taxAmount,
        netAmount: checkoutDto.netAmount,
        amountPaid,
        amountDue,
      });

      // Fetch shop details for snapshot
      const shop = await queryRunner.manager.query(`SELECT name, address, mobile_number FROM shops WHERE id = $1`, [shopId]);
      if (shop && shop.length > 0) {
        sale.shopNameSnapshot = shop[0].name;
        sale.shopAddressSnapshot = shop[0].address;
        sale.shopPhoneSnapshot = shop[0].mobile_number;
      }

      await queryRunner.manager.save(sale);

      // 4. Process Items (Lock, Deduct, Create SaleItems)
      for (const itemDto of checkoutDto.items) {
        const product = await queryRunner.manager.findOne(Product, {
          where: { id: itemDto.productId, shopId },
          lock: { mode: 'pessimistic_write' },
        });

        if (!product) {
          throw new NotFoundException(`Product ${itemDto.productId} not found`);
        }

        if (product.quantity < itemDto.quantity) {
          throw new BadRequestException(`Insufficient stock for ${product.name}. Available: ${product.quantity}, Requested: ${itemDto.quantity}`);
        }

        const quantityBefore = product.quantity;

        // Deduct inventory
        product.quantity -= itemDto.quantity;
        await queryRunner.manager.save(product);

        // Create SaleItem
        const subtotal = itemDto.quantity * itemDto.unitPrice;
        const saleItem = queryRunner.manager.create(SaleItem, {
          saleId: sale.id,
          productId: product.id,
          productName: product.name,
          quantity: itemDto.quantity,
          unitPrice: itemDto.unitPrice,
          purchasePrice: product.purchasePrice || 0,
          taxPercentage: itemDto.taxPercentage,
          subtotal,
        });
        await queryRunner.manager.save(saleItem);

        // Create Inventory Log
        const invLog = queryRunner.manager.create(InventoryLog, {
          shopId,
          productId: product.id,
          actionType: InventoryActionType.SALE,
          quantityBefore,
          quantityChange: -itemDto.quantity,
          quantityAfter: product.quantity,
          createdBy: user.id,
          createdByName: user.email || 'Unknown',
          notes: `Sold in Invoice ${invoiceNumber}`,
        });
        await queryRunner.manager.save(invLog);
      }

      // 5. Process Payments
      for (const paymentDto of checkoutDto.payments) {
        const payment = queryRunner.manager.create(Payment, {
          saleId: sale.id,
          amount: paymentDto.amount,
          paymentMethod: paymentDto.paymentMethod,
          status: 'success',
        });
        await queryRunner.manager.save(payment);

        // Update Customer Balance if credit
        if (paymentDto.paymentMethod === 'credit' && checkoutDto.customerId) {
          const customer = await queryRunner.manager.findOne(Customer, {
            where: { id: checkoutDto.customerId, shopId },
            lock: { mode: 'pessimistic_write' },
          });
          
          if (customer) {
            customer.currentBalance += paymentDto.amount; // credit means they owe us this amount
            await queryRunner.manager.save(customer);
          }
        }
      }

      // If there's an amount due not explicitly paid by 'credit', it's still owed by the customer
      // Some POS systems log unpaid amount as credit automatically. 
      // We will trust the client to pass 'credit' explicitly in payments list for the unpaid portion, 
      // OR we can auto-add it to customer balance here:
      if (amountDue > 0 && checkoutDto.customerId) {
         const customer = await queryRunner.manager.findOne(Customer, {
            where: { id: checkoutDto.customerId, shopId },
            lock: { mode: 'pessimistic_write' },
         });
         if (customer) {
            // Check if amountDue is already covered by a 'credit' payment
            const creditPaymentAmount = checkoutDto.payments
                .filter(p => p.paymentMethod === 'credit')
                .reduce((sum, p) => sum + p.amount, 0);
            
            const unpaidNotLoggedAsCredit = amountDue - creditPaymentAmount;
            if (unpaidNotLoggedAsCredit > 0) {
                 customer.currentBalance += unpaidNotLoggedAsCredit;
                 await queryRunner.manager.save(customer);
            }
         }
      }

      await queryRunner.commitTransaction();
      
      const finalSale = await this.saleRepository.findOne({
        where: { id: sale.id },
        relations: ['items', 'payments', 'customer'],
      });
      return finalSale!;
      
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw err;
    } finally {
      await queryRunner.release();
    }
  }

  async findAll(shopId: string, limit: number = 20, offset: number = 0, customerId?: string, startDate?: string, endDate?: string): Promise<{ data: Sale[], total: number }> {
    const qb = this.saleRepository.createQueryBuilder('sale')
      .leftJoinAndSelect('sale.customer', 'customer')
      .where('sale.shopId = :shopId', { shopId });

    if (customerId) {
      qb.andWhere('sale.customerId = :customerId', { customerId });
    }

    if (startDate && endDate) {
      qb.andWhere('sale.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate });
    }

    qb.orderBy('sale.createdAt', 'DESC')
      .skip(offset)
      .take(limit);

    const [data, total] = await qb.getManyAndCount();
    return { data, total };
  }

  async findOne(shopId: string, id: string): Promise<Sale> {
    const sale = await this.saleRepository.findOne({
      where: { shopId, id },
      relations: ['items', 'payments', 'customer'],
    });

    if (!sale) {
      throw new NotFoundException(`Sale #${id} not found`);
    }
    return sale;
  }
}
