import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from 'typeorm';
import { Matches } from 'class-validator';
import { User } from '../../users/entities/user.entity';

@Entity('shops')
export class Shop {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'shop_code', type: 'varchar', length: 20, unique: true })
  shopCode: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ name: 'owner_name', type: 'varchar', length: 255 })
  ownerName: string;

  @Column({ name: 'mobile_number', type: 'varchar', length: 15, nullable: true })
  mobileNumber: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string | null;

  @Column({ type: 'text', nullable: true })
  address: string | null;

  @Column({
    name: 'business_type',
    type: 'varchar',
    length: 50,
    default: 'general',
  })
  businessType: string;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @Column({
    name: 'subscription_status',
    type: 'varchar',
    length: 20,
    default: 'free',
  })
  subscriptionStatus: string;

  @OneToMany(() => User, (user) => user.shop)
  users: User[];

  @Column({ name: 'logo_url', type: 'varchar', length: 500, nullable: true })
  logoUrl?: string;

  @Column({ name: 'gst_number', type: 'varchar', length: 50, nullable: true })
  gstNumber?: string;


  @Column({ name: 'invoice_prefix', type: 'varchar', length: 10, default: 'INV' })
  @Matches(/^[A-Z]{2,10}$/, { message: 'Invoice prefix must be 2-10 uppercase letters' })
  invoicePrefix: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', type: 'timestamptz', nullable: true })
  deletedAt: Date | null;
}
