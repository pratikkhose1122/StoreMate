import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('invoice_sequences')
export class InvoiceSequence {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'shop_id' })
  shopId: string;

  @Column({ name: 'current_number', default: 0 })
  currentNumber: number;

  @Column({ name: 'financial_year' })
  financialYear: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
