import { Controller, Get, Post, Put, Body, Param, UseGuards } from '@nestjs/common';
import { StaffService } from './staff.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from '../auth/decorators/current-user.decorator';
import { RequirePermissions } from '../auth/decorators/require-permissions.decorator';
import { Permission } from '../auth/roles.enum';
import { PermissionsGuard } from '../auth/guards/permissions.guard';

@Controller('staff')
@UseGuards(JwtAuthGuard, PermissionsGuard)
export class StaffController {
  constructor(private readonly staffService: StaffService) {}

  @Get()
  @RequirePermissions(Permission.MANAGE_STAFF)
  async getStaff(@CurrentUser() user: JwtPayload) {
    if (!user.shopId) return [];
    const staff = await this.staffService.listStaff(user.shopId);
    return staff.map(s => ({
      id: s.id,
      name: s.name,
      mobileNumber: s.mobileNumber,
      role: s.role,
      isActive: s.isActive,
      isInvited: s.isInvited,
      invitedAt: s.invitedAt,
      joinedAt: s.joinedAt,
      lastLoginAt: s.lastLoginAt,
    }));
  }

  @Post()
  @RequirePermissions(Permission.MANAGE_STAFF)
  async inviteStaff(
    @CurrentUser() user: JwtPayload,
    @Body() body: { name: string; mobileNumber: string; role: string }
  ) {
    if (!user.shopId) throw new Error('No shopId');
    const saved = await this.staffService.inviteStaff(user.shopId, user.sub, body);
    return {
      id: saved.id,
      name: saved.name,
      mobileNumber: saved.mobileNumber,
      role: saved.role,
      isActive: saved.isActive,
      isInvited: saved.isInvited,
    };
  }

  @Put(':id')
  @RequirePermissions(Permission.MANAGE_STAFF)
  async updateStaff(
    @CurrentUser() user: JwtPayload,
    @Param('id') staffId: string,
    @Body() body: { role?: string; isActive?: boolean }
  ) {
    if (!user.shopId) throw new Error('No shopId');
    const updated = await this.staffService.updateStaff(user.shopId, user.sub, staffId, body);
    return {
      id: updated.id,
      name: updated.name,
      mobileNumber: updated.mobileNumber,
      role: updated.role,
      isActive: updated.isActive,
    };
  }
}
