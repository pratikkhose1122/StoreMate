import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { Product } from '../products/entities/product.entity';
import { Category } from '../categories/entities/category.entity';
import { InventoryLog } from '../inventory/entities/inventory-log.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Product, Category, InventoryLog])],
  controllers: [DashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
