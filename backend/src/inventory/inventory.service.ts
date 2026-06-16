import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { InventoryLog } from './entities/inventory-log.entity';
import { AdjustInventoryDto } from './dto/inventory.dto';
import { Product } from '../products/entities/product.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class InventoryService {
  constructor(
    @InjectRepository(InventoryLog)
    private readonly inventoryLogRepository: Repository<InventoryLog>,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Safely adjusts inventory within a database transaction.
   * Uses row-level pessimistic write lock to prevent race conditions.
   */
  async adjust(
    adjustDto: AdjustInventoryDto,
    shopId: string,
    userId: string,
  ): Promise<InventoryLog> {
    const queryRunner = this.dataSource.createQueryRunner();

    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // 1. Lock the product row
      const product = await queryRunner.manager
        .createQueryBuilder(Product, 'product')
        .where('product.id = :productId', { productId: adjustDto.productId })
        .andWhere('product.shopId = :shopId', { shopId })
        .setLock('pessimistic_write')
        .getOne();

      if (!product) {
        throw new NotFoundException('Product not found');
      }

      // 2. Fetch the user to get their name for the log snapshot
      const user = await queryRunner.manager.findOne(User, {
        where: { id: userId },
      });

      if (!user) {
        throw new NotFoundException('User not found');
      }

      // 3. Calculate new quantity
      const quantityBefore = product.quantity;
      const quantityAfter = quantityBefore + adjustDto.quantityChange;

      if (quantityAfter < 0) {
        throw new BadRequestException(
          `Insufficient stock. Current quantity is ${quantityBefore}, cannot adjust by ${adjustDto.quantityChange}.`,
        );
      }

      // 4. Update product quantity
      product.quantity = quantityAfter;
      await queryRunner.manager.save(Product, product);

      // 5. Create inventory log
      const log = this.inventoryLogRepository.create({
        shopId,
        productId: product.id,
        actionType: adjustDto.actionType,
        quantityBefore,
        quantityChange: adjustDto.quantityChange,
        quantityAfter,
        notes: adjustDto.notes,
        createdBy: user.id,
        createdByName: user.mobileNumber, // snapshot
      });

      const savedLog = await queryRunner.manager.save(InventoryLog, log);

      await queryRunner.commitTransaction();
      return savedLog;
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Fetch recent inventory logs for a shop or product.
   */
  async getLogs(shopId: string, productId?: string, limit: number = 50) {
    const where: any = { shopId };
    if (productId) {
      where.productId = productId;
    }

    return this.inventoryLogRepository.find({
      where,
      order: { createdAt: 'DESC' },
      take: limit,
      relations: ['product'],
    });
  }
  /**
   * Fetch paginated inventory history for a specific product.
   */
  async getHistory(shopId: string, productId: string, page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;
    const [data, total] = await this.inventoryLogRepository.findAndCount({
      where: { shopId, productId },
      order: { createdAt: 'DESC' },
      skip,
      take: limit,
      relations: ['product'],
    });

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
