import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsEmail,
  IsIn,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

const VALID_BUSINESS_TYPES = [
  'kirana',
  'electronics',
  'clothing',
  'hardware',
  'pharmacy',
  'restaurant',
  'general',
  'other',
] as const;

export type BusinessType = (typeof VALID_BUSINESS_TYPES)[number];

export class CreateShopDto {
  @IsNotEmpty({ message: 'Shop name is required' })
  @IsString()
  @MinLength(2, { message: 'Shop name must be at least 2 characters' })
  @MaxLength(100, { message: 'Shop name must not exceed 100 characters' })
  name: string;

  @IsNotEmpty({ message: 'Owner name is required' })
  @IsString()
  @MinLength(2, { message: 'Owner name must be at least 2 characters' })
  @MaxLength(100, { message: 'Owner name must not exceed 100 characters' })
  ownerName: string;

  @IsOptional()
  @IsString()
  @Matches(/^[6-9]\d{9}$/, {
    message: 'Mobile number must be a valid 10-digit Indian mobile number',
  })
  mobileNumber?: string;

  @IsOptional()
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'Address must not exceed 500 characters' })
  address?: string;

  @IsNotEmpty({ message: 'Business type is required' })
  @IsIn(VALID_BUSINESS_TYPES, {
    message: `Business type must be one of: ${VALID_BUSINESS_TYPES.join(', ')}`,
  })
  businessType: BusinessType;
}
