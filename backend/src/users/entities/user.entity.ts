import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from 'typeorm';
import { Shop } from '../../shops/entities/shop.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'shop_id', type: 'uuid', nullable: true })
  shopId: string | null;

  @ManyToOne(() => Shop, (shop) => shop.users, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'shop_id' })
  shop: Shop | null;

  @Column({
    name: 'mobile_number',
    type: 'varchar',
    length: 15,
    unique: true,
  })
  mobileNumber: string;

  @Column({
    name: 'firebase_uid',
    type: 'varchar',
    length: 128,
    unique: true,
    nullable: true,
  })
  firebaseUid: string | null;

  @Column({ type: 'varchar', length: 20, default: 'owner' })
  role: string;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @Column({ name: 'last_login_at', type: 'timestamptz', nullable: true })
  lastLoginAt: Date | null;

  @Column({ name: 'name', type: 'varchar', length: 100, nullable: true })
  name: string | null;

  @Column({ name: 'is_invited', type: 'boolean', default: true })
  isInvited: boolean;

  @Column({ name: 'invited_at', type: 'timestamptz', nullable: true })
  invitedAt: Date | null;

  @Column({ name: 'joined_at', type: 'timestamptz', nullable: true })
  joinedAt: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', type: 'timestamptz', nullable: true })
  deletedAt: Date | null;
}
