import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { Shop } from '../../shops/entities/shop.entity';
import { User } from '../../users/entities/user.entity';

export enum ActivityAction {
  USER_LOGIN = 'USER_LOGIN',
  PRODUCT_CREATED = 'PRODUCT_CREATED',
  PRODUCT_UPDATED = 'PRODUCT_UPDATED',
  PRODUCT_DELETED = 'PRODUCT_DELETED',
  INVENTORY_ADJUSTED = 'INVENTORY_ADJUSTED',
  SALE_CREATED = 'SALE_CREATED',
  SALE_CANCELLED = 'SALE_CANCELLED',
  CUSTOMER_CREATED = 'CUSTOMER_CREATED',
  STAFF_CREATED = 'STAFF_CREATED',
  STAFF_UPDATED = 'STAFF_UPDATED',
  SETTINGS_UPDATED = 'SETTINGS_UPDATED',
}

@Entity('activity_logs')
export class ActivityLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'shop_id', type: 'uuid' })
  shopId: string;

  @ManyToOne(() => Shop, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'shop_id' })
  shop: Shop;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({
    type: 'varchar',
    length: 100,
  })
  action: string; // Storing as string to handle legacy or new actions easily

  @Column({ name: 'entity_type', type: 'varchar', length: 50, nullable: true })
  entityType?: string;

  @Column({ name: 'entity_id', type: 'varchar', length: 100, nullable: true })
  entityId?: string;

  @Column({ type: 'jsonb', nullable: true })
  details?: Record<string, any>;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;
}
