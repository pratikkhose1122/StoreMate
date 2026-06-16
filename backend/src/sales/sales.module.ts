import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SalesService } from './sales.service';
import { SalesController } from './sales.controller';
import { Sale } from './entities/sale.entity';
import { SaleItem } from './entities/sale-item.entity';
import { Payment } from './entities/payment.entity';
import { InvoiceSequence } from './entities/invoice-sequence.entity';
import { Product } from '../products/entities/product.entity';
import { Customer } from '../customers/entities/customer.entity';
import { InventoryLog } from '../inventory/entities/inventory-log.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Sale, SaleItem, Payment, InvoiceSequence, Product, Customer, InventoryLog]),
  ],
  controllers: [SalesController],
  providers: [SalesService],
  exports: [SalesService],
})
export class SalesModule {}
