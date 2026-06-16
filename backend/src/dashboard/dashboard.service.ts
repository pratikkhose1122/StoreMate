import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, DataSource } from 'typeorm';
import { Product } from '../products/entities/product.entity';
import { Category } from '../categories/entities/category.entity';
import { InventoryLog } from '../inventory/entities/inventory-log.entity';

export interface DashboardSummary {
  totalProducts: number;
  totalCategories: number;
  lowStockProducts: number;
  outOfStockProducts: number;
  inventoryValue: number;
  todaysSales: number;
  todaysProfit: number;
  recentMovements: any[];
  recentProducts: any[];
  lowStockProductsList: any[];
}

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
    @InjectRepository(InventoryLog)
    private readonly inventoryLogRepository: Repository<InventoryLog>,
    private readonly dataSource: DataSource,
  ) {}

  async getSummary(shopId: string): Promise<DashboardSummary> {
    const totalCategories = await this.categoryRepository.count({
      where: { shopId },
    });

    const products = await this.productRepository.find({
      where: { shopId },
      select: ['id', 'name', 'quantity', 'lowStockThreshold', 'purchasePrice', 'imageUrl'],
      order: { createdAt: 'DESC' },
    });

    let totalProducts = 0;
    let lowStockProducts = 0;
    let outOfStockProducts = 0;
    let inventoryValue = 0;
    
    const lowStockProductsList = [];

    for (const p of products) {
      totalProducts++;
      if (p.quantity === 0) {
        outOfStockProducts++;
      }
      
      if (p.quantity <= p.lowStockThreshold) {
        lowStockProducts++;
        if (lowStockProductsList.length < 5) {
          lowStockProductsList.push(p);
        }
      }
      
      // inventoryValue uses purchase_price for cost-basis valuation
      inventoryValue += p.quantity * p.purchasePrice;
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Calculate Today's Sales and Profit
    const todaySalesData = await this.dataSource.query(`
      SELECT 
        SUM(s.net_amount) as todays_sales,
        SUM(si.subtotal - (si.purchase_price * si.quantity)) as todays_profit
      FROM sales s
      LEFT JOIN sale_items si ON si.sale_id = s.id
      WHERE s.shop_id = $1 AND s.created_at >= $2 AND s.status = 'completed'
    `, [shopId, today]);

    const todaysSales = Number(todaySalesData[0]?.todays_sales || 0);
    const todaysProfit = Number(todaySalesData[0]?.todays_profit || 0);

    const recentProducts = products.slice(0, 5);

    const recentMovements = await this.inventoryLogRepository.find({
      where: { shopId },
      order: { createdAt: 'DESC' },
      take: 5,
      relations: ['product'],
    });

    return {
      totalProducts,
      totalCategories,
      lowStockProducts,
      outOfStockProducts,
      inventoryValue,
      recentMovements,
      recentProducts,
      lowStockProductsList,
      todaysSales,
      todaysProfit,
    };
  }
}
