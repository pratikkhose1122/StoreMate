import { IsString, IsOptional, Matches, IsUrl } from 'class-validator';

export class UpdateShopSettingsDto {
  @IsOptional()
  @IsUrl({}, { message: 'Logo must be a valid URL' })
  logoUrl?: string | null;

  @IsOptional()
  @IsString()
  gstNumber?: string;

  @IsOptional()
  @IsString()
  businessType?: string;

  @IsOptional()
  @Matches(/^[A-Z]{2,10}$/, { message: 'Invoice prefix must be 2-10 uppercase letters' })
  invoicePrefix?: string;
}
