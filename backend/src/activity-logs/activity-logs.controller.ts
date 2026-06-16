import { Controller, Get, UseGuards, Query } from '@nestjs/common';
import { ActivityLogsService } from './activity-logs.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from '../auth/decorators/current-user.decorator';
import { RequirePermissions } from '../auth/decorators/require-permissions.decorator';
import { Permission } from '../auth/roles.enum';
import { PermissionsGuard } from '../auth/guards/permissions.guard';

@Controller('activity-logs')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class ActivityLogsController {
  constructor(private readonly activityLogsService: ActivityLogsService) {}

  @Get('recent')
  @RequirePermissions(Permission.VIEW_REPORTS)
  async getRecentActivity(@CurrentUser() user: JwtPayload, @Query('limit') limitStr?: string) {
    if (!user.shopId) {
      return [];
    }
    const limit = limitStr ? parseInt(limitStr, 10) : 20;
    const logs = await this.activityLogsService.getRecentActivity(user.shopId, limit);
    return logs.map(log => ({
      id: log.id,
      action: log.action,
      entityType: log.entityType,
      entityId: log.entityId,
      details: log.details,
      createdAt: log.createdAt,
      user: {
        id: log.user.id,
        name: log.user.name,
        role: log.user.role,
        mobileNumber: log.user.mobileNumber,
      }
    }));
  }
}
