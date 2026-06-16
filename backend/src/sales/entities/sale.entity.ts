import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { Shop } from '../../shops/entities/shop.entity';
import { Customer } from '../../customers/entities/customer.entity';
import { SaleItem } from './sale-item.entity';
import { Payment } from './payment.entity';
import { DecimalColumnTransformer } from '../../common/transformers/decimal.transformer';

@Entity('sales')
export class Sale {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'shop_id' })
  shopId: string;

  @ManyToOne(() => Shop)
  @JoinColumn({ name: 'shop_id' })
  shop: Shop;

  @Column({ name: 'customer_id', nullable: true })
  customerId: string;

  @ManyToOne(() => Customer)
  @JoinColumn({ name: 'customer_id' })
  customer: Customer;

  @Column({ name: 'invoice_number' })
  invoiceNumber: string;

  @Column({ default: 'completed' })
  status: string; // draft, completed, cancelled, refunded

  @Column({ name: 'total_amount', type: 'decimal', precision: 12, scale: 2, default: 0, transformer: new DecimalColumnTransformer() })
  totalAmount: number;

  @Column({ name: 'discount_amount', type: 'decimal', precision: 12, scale: 2, default: 0, transformer: new DecimalColumnTransformer() })
  discountAmount: number;

  @Column({ name: 'tax_amount', type: 'decimal', precision: 12, scale: 2, default: 0, transformer: new DecimalColumnTransformer() })
  taxAmount: number;

  @Column({ name: 'net_amount', type: 'decimal', precision: 12, scale: 2, default: 0, transformer: new DecimalColumnTransformer() })
  netAmount: number;

  @Column({ name: 'amount_paid', type: 'decimal', precision: 12, scale: 2, default: 0, transformer: new DecimalColumnTransformer() })
  amountPaid: number;

  @Column({ name: 'amount_due', type: 'decimal', precision: 12, scale: 2, default: 0, transformer: new DecimalColumnTransformer() })
  amountDue: number;

  @Column({ name: 'shop_name_snapshot', nullable: true })
  shopNameSnapshot: string;

  @Column({ name: 'shop_address_snapshot', type: 'text', nullable: true })
  shopAddressSnapshot: string;

  @Column({ name: 'shop_phone_snapshot', type: 'varchar', length: 20, nullable: true })
  shopPhoneSnapshot?: string;

  @Column({ name: 'shop_gst_snapshot', type: 'varchar', length: 50, nullable: true })
  shopGstSnapshot?: string;

  @OneToMany(() => SaleItem, item => item.sale)
  items: SaleItem[];

  @OneToMany(() => Payment, payment => payment.sale)
  payments: Payment[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
