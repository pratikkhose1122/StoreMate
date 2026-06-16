import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Sale } from './sale.entity';
import { DecimalColumnTransformer } from '../../common/transformers/decimal.transformer';

@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'sale_id' })
  saleId: string;

  @ManyToOne(() => Sale, sale => sale.payments)
  @JoinColumn({ name: 'sale_id' })
  sale: Sale;

  @Column({ type: 'decimal', precision: 12, scale: 2, transformer: new DecimalColumnTransformer() })
  amount: number;

  @Column({ name: 'payment_method' })
  paymentMethod: string; // cash, upi, card, bank_transfer, credit

  @Column({ default: 'success' })
  status: string; // success, pending, failed

  @Column({ name: 'transaction_id', nullable: true })
  transactionId: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
