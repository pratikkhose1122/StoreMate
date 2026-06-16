import { Injectable, StreamableFile } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Sale } from '../sales/entities/sale.entity';
import { SaleItem } from '../sales/entities/sale-item.entity';
import { Product } from '../products/entities/product.entity';
import { Customer } from '../customers/entities/customer.entity';
import { InventoryLog } from '../inventory/entities/inventory-log.entity';
import { Readable } from 'stream';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Sale) private saleRepo: Repository<Sale>,
    @InjectRepository(SaleItem) private saleItemRepo: Repository<SaleItem>,
    @InjectRepository(Product) private productRepo: Repository<Product>,
    @InjectRepository(Customer) private customerRepo: Repository<Customer>,
    @InjectRepository(InventoryLog) private logRepo: Repository<InventoryLog>,
  ) {}

  async getSalesData(shopId: string, startDate: string, endDate: string) {
    const start = startDate ? new Date(startDate) : new Date(new Date().setHours(0,0,0,0));
    const end = endDate ? new Date(endDate) : new Date();

    const sales = await this.saleRepo.find({
      where: { shopId, createdAt: Between(start, end) },
      order: { createdAt: 'ASC' },
    });

    const totalSales = sales.reduce((sum, sale) => sum + Number(sale.netAmount), 0);
    return { totalSales, count: sales.length, sales };
  }

  async getProfitData(shopId: string, startDate: string, endDate: string) {
    const start = startDate ? new Date(startDate) : new Date(new Date().setHours(0,0,0,0));
    const end = endDate ? new Date(endDate) : new Date();

    const items = await this.saleItemRepo.createQueryBuilder('item')
      .innerJoin('item.sale', 'sale')
      .where('sale.shopId = :shopId', { shopId })
      .andWhere('sale.createdAt BETWEEN :start AND :end', { start, end })
      .getMany();

    const totalProfit = items.reduce((sum, item) => {
      const revenue = Number(item.subtotal);
      const cost = Number(item.unitPrice) * 0.7 * item.quantity; // Defaulting to 70% of unitPrice as we don't have purchase price here
      return sum + (revenue - cost);
    }, 0);

    return { totalProfit, count: items.length };
  }

  async getTopProducts(shopId: string) {
    return this.saleItemRepo.createQueryBuilder('item')
      .innerJoin('item.sale', 'sale')
      .select('item.productId', 'productId')
      .addSelect('item.productName', 'productName')
      .addSelect('SUM(item.quantity)', 'totalQuantitySold')
      .where('sale.shopId = :shopId', { shopId })
      .groupBy('item.productId, item.productName')
      .orderBy('"totalQuantitySold"', 'DESC')
      .limit(10)
      .getRawMany();
  }

  async getSlowProducts(shopId: string) {
    // Products with least quantity sold
    // Could also outer join from Products table to find 0 sales
    const soldProductIdsQuery = this.saleItemRepo.createQueryBuilder('item')
      .innerJoin('item.sale', 'sale')
      .select('item.productId')
      .where('sale.shopId = :shopId');

    const slowProducts = await this.productRepo.createQueryBuilder('product')
      .where('product.shopId = :shopId', { shopId })
      .andWhere(`product.id NOT IN (${soldProductIdsQuery.getQuery()})`)
      .setParameters(soldProductIdsQuery.getParameters())
      .limit(10)
      .getMany();
      
    // If we want slow moving (sold a little bit), we can union. For now 0 sales is slow.
    return slowProducts;
  }

  async exportProducts(shopId: string): Promise<StreamableFile> {
    const products = await this.productRepo.find({ where: { shopId } });
    const header = 'id,name,sku,barcode,selling_price,purchase_price,quantity\n';
    const rows = products.map(p => `${p.id},"${p.name}",${p.sku || ''},${p.barcode || ''},${p.sellingPrice},${p.purchasePrice},${p.quantity}`).join('\n');
    return new StreamableFile(Readable.from([header + rows]), { type: 'text/csv' });
  }

  async exportCustomers(shopId: string): Promise<StreamableFile> {
    const customers = await this.customerRepo.find({ where: { shopId } });
    const header = 'id,name,mobile,email,current_balance\n';
    const rows = customers.map(c => `${c.id},"${c.name}",${c.mobileNumber || ''},${c.email || ''},${c.currentBalance}`).join('\n');
    return new StreamableFile(Readable.from([header + rows]), { type: 'text/csv' });
  }

  async exportSales(shopId: string): Promise<StreamableFile> {
    const sales = await this.saleRepo.find({ where: { shopId } });
    const header = 'invoice_number,date,net_amount,amount_paid,amount_due\n';
    const rows = sales.map(s => `${s.invoiceNumber},${s.createdAt.toISOString()},${s.netAmount},${s.amountPaid},${s.amountDue}`).join('\n');
    return new StreamableFile(Readable.from([header + rows]), { type: 'text/csv' });
  }

  async exportInventoryLogs(shopId: string): Promise<StreamableFile> {
    const logs = await this.logRepo.find({ where: { shopId }, relations: ['product'] });
    const header = 'date,product_name,action_type,quantity_change,reference_id\n';
    const rows = logs.map(l => `${l.createdAt.toISOString()},"${l.product.name}",${l.actionType},${l.quantityChange},"${l.notes || ''}"`).join('\n');
    return new StreamableFile(Readable.from([header + rows]), { type: 'text/csv' });
  }
}
