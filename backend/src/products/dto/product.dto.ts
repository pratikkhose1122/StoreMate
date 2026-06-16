import {
  IsString,
  IsNotEmpty,
  MaxLength,
  MinLength,
  IsOptional,
  IsNumber,
  Min,
  IsInt,
  IsIn,
  IsUUID,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(255)
  name: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsUUID()
  @IsOptional()
  categoryId?: string;

  @IsString()
  @IsOptional()
  @MaxLength(50)
  sku?: string;

  @IsString()
  @IsOptional()
  @MaxLength(100)
  barcode?: string;

  @IsString()
  @IsOptional()
  imageUrl?: string;

  @IsNumber()
  @Min(0)
  @Type(() => Number)
  purchasePrice: number;

  @IsNumber()
  @Min(0)
  @Type(() => Number)
  sellingPrice: number;

  @IsInt()
  @Min(0)
  @Type(() => Number)
  @IsOptional()
  quantity?: number;

  @IsInt()
  @Min(0)
  @Type(() => Number)
  @IsOptional()
  lowStockThreshold?: number;

  @IsString()
  @IsOptional()
  @IsIn(['piece', 'kg', 'gram', 'litre', 'ml', 'meter', 'pack', 'box'])
  unitType?: string;

  @IsString()
  @IsOptional()
  @IsIn(['active', 'inactive', 'out_of_stock', 'archived'])
  status?: string;
}

export class UpdateProductDto {
  @IsString()
  @IsOptional()
  @MinLength(2)
  @MaxLength(255)
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsUUID()
  @IsOptional()
  categoryId?: string | null;

  @IsString()
  @IsOptional()
  @MaxLength(50)
  sku?: string | null;

  @IsString()
  @IsOptional()
  @MaxLength(100)
  barcode?: string | null;

  @IsString()
  @IsOptional()
  imageUrl?: string | null;

  @IsNumber()
  @Min(0)
  @Type(() => Number)
  @IsOptional()
  purchasePrice?: number;

  @IsNumber()
  @Min(0)
  @Type(() => Number)
  @IsOptional()
  sellingPrice?: number;

  @IsInt()
  @Min(0)
  @Type(() => Number)
  @IsOptional()
  lowStockThreshold?: number;

  @IsString()
  @IsOptional()
  @IsIn(['piece', 'kg', 'gram', 'litre', 'ml', 'meter', 'pack', 'box'])
  unitType?: string;

  @IsString()
  @IsOptional()
  @IsIn(['active', 'inactive', 'out_of_stock', 'archived'])
  status?: string;
}

export class ProductQueryDto {
  @IsInt()
  @Min(1)
  @Type(() => Number)
  @IsOptional()
  page?: number = 1;

  @IsInt()
  @Min(1)
  @Type(() => Number)
  @IsOptional()
  limit?: number = 20;

  @IsString()
  @IsOptional()
  search?: string;

  @IsUUID()
  @IsOptional()
  categoryId?: string;
}
