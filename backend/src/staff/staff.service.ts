import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { ActivityLogsService } from '../activity-logs/activity-logs.service';
import { ActivityAction } from '../activity-logs/entities/activity-log.entity';

@Injectable()
export class StaffService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly activityLogsService: ActivityLogsService,
  ) {}

  async listStaff(shopId: string): Promise<User[]> {
    return this.userRepo.find({
      where: { shopId },
      order: { createdAt: 'DESC' },
    });
  }

  async inviteStaff(shopId: string, inviterId: string, data: { name: string; mobileNumber: string; role: string }): Promise<User> {
    const existing = await this.userRepo.findOne({ where: { mobileNumber: data.mobileNumber } });
    if (existing) {
      throw new ConflictException('User with this mobile number already exists');
    }

    const user = this.userRepo.create({
      shopId,
      name: data.name,
      mobileNumber: data.mobileNumber,
      role: data.role,
      isInvited: true,
      invitedAt: new Date(),
      isActive: true,
      // firebaseUid might be required but we made it nullable
    });

    const savedUser = await this.userRepo.save(user);

    await this.activityLogsService.logAction({
      shopId,
      userId: inviterId,
      action: ActivityAction.STAFF_CREATED,
      entityType: 'User',
      entityId: savedUser.id,
      details: { name: savedUser.name, role: savedUser.role },
    });

    return savedUser;
  }

  async updateStaff(shopId: string, updaterId: string, staffId: string, data: { role?: string; isActive?: boolean }): Promise<User> {
    const user = await this.userRepo.findOne({ where: { id: staffId, shopId } });
    if (!user) {
      throw new NotFoundException('Staff not found');
    }

    if (data.role !== undefined) user.role = data.role;
    if (data.isActive !== undefined) user.isActive = data.isActive;

    const savedUser = await this.userRepo.save(user);

    await this.activityLogsService.logAction({
      shopId,
      userId: updaterId,
      action: ActivityAction.STAFF_UPDATED,
      entityType: 'User',
      entityId: savedUser.id,
      details: { role: savedUser.role, isActive: savedUser.isActive },
    });

    return savedUser;
  }
}
