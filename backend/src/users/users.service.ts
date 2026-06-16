import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Find a user by their Firebase UID, including their shop relation.
   */
  async findByFirebaseUid(firebaseUid: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { firebaseUid },
      relations: ['shop'],
    });
  }

  /**
   * Find a user by their internal UUID, including their shop relation.
   */
  async findByIdWithShop(userId: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { id: userId },
      relations: ['shop'],
    });
  }

  /**
   * Find a user by mobile number.
   */
  async findByMobileNumber(mobileNumber: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { mobileNumber },
    });
  }

  /**
   * Create a new user during first login.
   * The user will not have a shop_id until shop registration.
   */
  async create(data: {
    firebaseUid: string;
    mobileNumber: string;
  }): Promise<User> {
    const user = this.userRepository.create({
      firebaseUid: data.firebaseUid,
      mobileNumber: data.mobileNumber,
      role: 'owner',
      isActive: true,
      lastLoginAt: new Date(),
    });

    const savedUser = await this.userRepository.save(user);
    this.logger.log(
      `New user created: ${savedUser.id} (${savedUser.mobileNumber})`,
    );

    return savedUser;
  }

  /**
   * Update the user's last login timestamp.
   */
  async updateLastLogin(userId: string): Promise<void> {
    await this.userRepository.update(userId, {
      lastLoginAt: new Date(),
    });
  }

  /**
   * Accept an invite and link firebaseUid.
   */
  async acceptInvite(userId: string, firebaseUid: string): Promise<void> {
    await this.userRepository.update(userId, {
      firebaseUid,
      isInvited: false,
      joinedAt: new Date(),
      lastLoginAt: new Date(),
    });
  }

  /**
   * Link a user to a shop by setting their shop_id.
   */
  async linkToShop(userId: string, shopId: string): Promise<void> {
    await this.userRepository.update(userId, { shopId });
    this.logger.log(`User ${userId} linked to shop ${shopId}`);
  }
}
