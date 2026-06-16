import { IsEnum, IsInt, IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';
import { Type } from 'class-transformer';
import { InventoryActionType } from '../entities/inventory-log.entity';

export class AdjustInventoryDto {
  @IsUUID()
  @IsNotEmpty()
  productId: string;

  @IsInt()
  @Type(() => Number)
  @IsNotEmpty()
  quantityChange: number;

  @IsEnum(InventoryActionType)
  @IsNotEmpty()
  actionType: InventoryActionType;

  @IsString()
  @IsOptional()
  notes?: string;
}
