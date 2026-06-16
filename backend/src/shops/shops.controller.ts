import {
  Controller,
  Post,
  Put,
  Body,
  UseGuards,
  UseInterceptors,
  HttpCode,
  HttpStatus,
  BadRequestException,
  Inject,
  UploadedFile,
  Delete,
  NotFoundException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { StorageProvider } from '../storage/storage.provider';
import { ShopsService } from './shops.service';
import { CreateShopDto } from './dto/create-shop.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from '../auth/decorators/current-user.decorator';
import { AuthService } from '../auth/auth.service';

@Controller('shops')
@UseGuards(JwtAuthGuard)
export class ShopsController {
  constructor(
    private readonly shopsService: ShopsService,
    private readonly authService: AuthService,
  ) {}

  /**
   * POST /api/v1/shops
   *
   * Register a new shop for the authenticated user.
   *
   * Process:
   * 1. Validate the request body
   * 2. Create the shop in a transaction (shop + user link)
   * 3. Generate a new JWT with the shop_id included
   * 4. Return the shop data + updated JWT
   *
   * The client should replace its stored JWT with the new one,
   * as it now contains the shop_id for multi-tenant authorization.
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Body() createShopDto: CreateShopDto,
    @CurrentUser() currentUser: JwtPayload,
  ) {
    const { shop, user } = await this.shopsService.create(
      createShopDto,
      currentUser.sub,
    );

    // Generate a new JWT that includes the shop_id
    const accessToken = this.authService.generateJwt(user);

    return {
      shop: {
        id: shop.id,
        shopCode: shop.shopCode,
        name: shop.name,
        ownerName: shop.ownerName,
        mobileNumber: shop.mobileNumber,
        email: shop.email,
        address: shop.address,
        businessType: shop.businessType,
        subscriptionStatus: shop.subscriptionStatus,
        createdAt: shop.createdAt,
      },
      accessToken,
    };
  }

  @Put('settings')
  async updateSettings(
    @Body() updateSettingsDto: import('./dto/update-shop-settings.dto').UpdateShopSettingsDto,
    @CurrentUser() currentUser: JwtPayload,
  ) {
    if (!currentUser.shopId) {
      throw new BadRequestException('No shop associated with current user');
    }

    const updatedShop = await this.shopsService.updateSettings(
      currentUser.shopId,
      updateSettingsDto,
    );

    return {
      message: 'Settings updated successfully',
      shop: {
        id: updatedShop.id,
        shopCode: updatedShop.shopCode,
        name: updatedShop.name,
        logoUrl: updatedShop.logoUrl,
        gstNumber: updatedShop.gstNumber,
        businessType: updatedShop.businessType,
      },
    };
  }

  @Post('logo')
  @UseInterceptors(FileInterceptor('logo'))
  async uploadLogo(
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() currentUser: JwtPayload,
    @Inject('StorageProvider') storageProvider: StorageProvider,
  ) {
    if (!currentUser.shopId) {
      throw new BadRequestException('No shop associated with current user');
    }
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    // Validate MIME type
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedMimeTypes.includes(file.mimetype)) {
      throw new BadRequestException('Invalid file type. Only JPEG, PNG, and WebP are allowed.');
    }

    // Validate file size (2MB max)
    const maxSize = 2 * 1024 * 1024;
    if (file.size > maxSize) {
      throw new BadRequestException('File size exceeds the 2MB limit.');
    }

    // Get current shop to find old logo
    const currentShop = await this.shopsService.findById(currentUser.shopId);
    if (!currentShop) throw new NotFoundException('Shop not found');

    const ext = file.originalname.split('.').pop();
    const filePath = `shop-logos/${currentUser.shopId}/logo-${Date.now()}.${ext}`;
    
    const logoUrl = await storageProvider.replaceFile(currentShop.logoUrl, filePath, file.buffer, file.mimetype);

    const updatedShop = await this.shopsService.updateSettings(currentUser.shopId, { logoUrl });

    return {
      message: 'Logo uploaded successfully',
      logoUrl: updatedShop.logoUrl,
    };
  }

  @Delete('logo')
  async deleteLogo(
    @CurrentUser() currentUser: JwtPayload,
    @Inject('StorageProvider') storageProvider: StorageProvider,
  ) {
    if (!currentUser.shopId) {
      throw new BadRequestException('No shop associated with current user');
    }

    const currentShop = await this.shopsService.findById(currentUser.shopId);
    if (!currentShop) throw new NotFoundException('Shop not found');
    
    if (currentShop.logoUrl) {
      await storageProvider.deleteFile(currentShop.logoUrl);
      await this.shopsService.updateSettings(currentUser.shopId, { logoUrl: null });
    }

    return {
      message: 'Logo deleted successfully',
    };
  }
}
