import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Sale } from './sale.entity';
import { Product } from '../../products/entities/product.entity';
import { DecimalColumnTransformer } from '../../common/transformers/decimal.transformer';

@Entity('sale_items')
export class SaleItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'sale_id' })
  saleId: string;

  @ManyToOne(() => Sale, sale => sale.items)
  @JoinColumn({ name: 'sale_id' })
  sale: Sale;

  @Column({ name: 'product_id', nullable: true })
  productId: string;

  @ManyToOne(() => Product)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @Column({ name: 'product_name' })
  productName: string;

  @Column()
  quantity: number;

  @Column({ name: 'unit_price', type: 'decimal', precision: 12, scale: 2, transformer: new DecimalColumnTransformer() })
  unitPrice: number;

  @Column({ name: 'purchase_price', type: 'decimal', precision: 12, scale: 2, default: 0, transformer: new DecimalColumnTransformer() })
  purchasePrice: number;

  @Column({ name: 'tax_percentage', type: 'decimal', precision: 5, scale: 2, default: 0, transformer: new DecimalColumnTransformer() })
  taxPercentage: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, transformer: new DecimalColumnTransformer() })
  subtotal: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
