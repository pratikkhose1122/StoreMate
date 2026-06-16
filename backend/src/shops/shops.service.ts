import {
  Injectable,
  ConflictException,
  Logger,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { Shop } from './entities/shop.entity';
import { User } from '../users/entities/user.entity';
import { CreateShopDto } from './dto/create-shop.dto';

interface CreateShopResult {
  shop: Shop;
  user: User;
}

@Injectable()
export class ShopsService {
  private readonly logger = new Logger(ShopsService.name);

  constructor(
    @InjectRepository(Shop)
    private readonly shopRepository: Repository<Shop>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Create a new shop and link it to the authenticated user.
   *
   * Uses a database transaction to ensure atomicity:
   * 1. Generate a unique shop_code from the sequence
   * 2. Create the shop record
   * 3. Update the user's shop_id
   * 4. Return both the shop and updated user
   *
   * If any step fails, the entire transaction is rolled back.
   */
  async create(
    createShopDto: CreateShopDto,
    userId: string,
  ): Promise<CreateShopResult> {
    // Verify user exists and doesn't already have a shop
    const existingUser = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['shop'],
    });

    if (!existingUser) {
      throw new BadRequestException('User not found');
    }

    if (existingUser.shopId) {
      throw new ConflictException('User already has a registered shop');
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Step 1: Generate shop code from PostgreSQL sequence
      const seqResult = await queryRunner.query(
        "SELECT nextval('shop_code_seq')",
      );
      const seqNum = parseInt(seqResult[0].nextval, 10);
      const shopCode = `STM-${String(seqNum).padStart(4, '0')}`;

      // Step 2: Create shop record
      const shop = queryRunner.manager.create(Shop, {
        shopCode,
        name: createShopDto.name,
        ownerName: createShopDto.ownerName,
        mobileNumber: createShopDto.mobileNumber || null,
        email: createShopDto.email || null,
        address: createShopDto.address || null,
        businessType: createShopDto.businessType,
        isActive: true,
        subscriptionStatus: 'free',
      });

      const savedShop = await queryRunner.manager.save(Shop, shop);
      this.logger.log(
        `Shop created: ${savedShop.shopCode} — "${savedShop.name}"`,
      );

      // Step 3: Link user to shop
      await queryRunner.manager.update(User, userId, {
        shopId: savedShop.id,
      });

      // Commit the transaction
      await queryRunner.commitTransaction();

      // Step 4: Fetch the updated user with shop relation
      const updatedUser = await this.userRepository.findOne({
        where: { id: userId },
        relations: ['shop'],
      });

      if (!updatedUser) {
        throw new BadRequestException('Failed to retrieve updated user');
      }

      return { shop: savedShop, user: updatedUser };
    } catch (error) {
      await queryRunner.rollbackTransaction();

      if ((error as { code?: string }).code === '23505') {
        throw new ConflictException(
          'A shop with this information already exists',
        );
      }

      this.logger.error(
        `Shop creation failed for user ${userId}: ${(error as Error).message}`,
      );
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Find a shop by its ID.
   */
  async findById(shopId: string): Promise<Shop | null> {
    return this.shopRepository.findOne({
      where: { id: shopId },
    });
  }

  /**
   * Find a shop by its shop code (e.g., STM-0001).
   */
  async findByShopCode(shopCode: string): Promise<Shop | null> {
    return this.shopRepository.findOne({
      where: { shopCode },
    });
  }

  /**
   * Update shop settings
   */
  async updateSettings(shopId: string, settingsDto: import('./dto/update-shop-settings.dto').UpdateShopSettingsDto): Promise<Shop> {
    const shop = await this.shopRepository.findOne({ where: { id: shopId } });
    if (!shop) {
      throw new NotFoundException(`Shop with ID ${shopId} not found`);
    }

    if (settingsDto.logoUrl !== undefined) shop.logoUrl = settingsDto.logoUrl ?? undefined;
    if (settingsDto.gstNumber !== undefined) shop.gstNumber = settingsDto.gstNumber;
    if (settingsDto.businessType !== undefined) shop.businessType = settingsDto.businessType;
    if (settingsDto.invoicePrefix !== undefined) shop.invoicePrefix = settingsDto.invoicePrefix;

    return this.shopRepository.save(shop);
  }
}
