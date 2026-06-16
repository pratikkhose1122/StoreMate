import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ActivityLog, ActivityAction } from './entities/activity-log.entity';

@Injectable()
export class ActivityLogsService {
  private readonly logger = new Logger(ActivityLogsService.name);

  constructor(
    @InjectRepository(ActivityLog)
    private readonly activityLogRepo: Repository<ActivityLog>,
  ) {}

  async logAction(data: {
    shopId: string;
    userId: string;
    action: ActivityAction;
    entityType?: string;
    entityId?: string;
    details?: Record<string, any>;
  }): Promise<ActivityLog> {
    try {
      const log = this.activityLogRepo.create({
        shopId: data.shopId,
        userId: data.userId,
        action: data.action,
        entityType: data.entityType,
        entityId: data.entityId,
        details: data.details,
      });
      return await this.activityLogRepo.save(log);
    } catch (e) {
      this.logger.error(`Failed to create activity log: ${e.message}`, e.stack);
      // We don't want to throw and break business logic if logging fails
      return null as any;
    }
  }

  async getRecentActivity(shopId: string, limit: number = 20): Promise<ActivityLog[]> {
    return this.activityLogRepo.find({
      where: { shopId },
      relations: ['user'],
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }
}
