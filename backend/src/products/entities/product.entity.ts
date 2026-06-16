import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { Shop } from '../../shops/entities/shop.entity';
import { Category } from '../../categories/entities/category.entity';
import { DecimalColumnTransformer } from '../../common/transformers/decimal.transformer';

@Entity('products')
@Index('idx_products_shop_id', ['shopId'])
@Index('idx_products_category_id', ['categoryId'])
@Index('idx_products_sku', ['sku'])
@Index('idx_products_barcode', ['barcode'])
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'shop_id', type: 'uuid' })
  shopId: string;

  @ManyToOne(() => Shop, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'shop_id' })
  shop: Shop;

  @Column({ name: 'category_id', type: 'uuid', nullable: true })
  categoryId?: string;

  @ManyToOne(() => Category, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'category_id' })
  category?: Category;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  sku?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  barcode?: string;

  @Column({ name: 'image_url', type: 'text', nullable: true })
  imageUrl?: string;

  @Column({
    name: 'purchase_price',
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: new DecimalColumnTransformer(),
  })
  purchasePrice: number;

  @Column({
    name: 'selling_price',
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: new DecimalColumnTransformer(),
  })
  sellingPrice: number;

  @Column({ type: 'integer', default: 0 })
  quantity: number;

  @Column({ name: 'low_stock_threshold', type: 'integer', default: 5 })
  lowStockThreshold: number;

  @Column({ name: 'unit_type', type: 'varchar', length: 20, default: 'piece' })
  unitType: string;

  @Column({ type: 'varchar', length: 20, default: 'active' })
  status: string;

  @Column({
    name: 'tax_percentage',
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 0,
    transformer: new DecimalColumnTransformer(),
  })
  taxPercentage: number;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', type: 'timestamptz' })
  deletedAt?: Date;
}
