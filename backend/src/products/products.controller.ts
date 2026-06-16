import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  Inject,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { StorageProvider } from '../storage/storage.provider';
import { ProductsService } from './products.service';
import { ProductsBulkService } from './products-bulk.service';
import {
  CreateProductDto,
  UpdateProductDto,
  ProductQueryDto,
} from './dto/product.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from '../auth/decorators/current-user.decorator';

@Controller('products')
@UseGuards(JwtAuthGuard)
export class ProductsController {
  constructor(
    private readonly productsService: ProductsService,
    private readonly productsBulkService: ProductsBulkService,
  ) {}

  @Post()
  create(@Body() createProductDto: CreateProductDto, @CurrentUser() user: JwtPayload) {
    return this.productsService.create(createProductDto, user.shopId as string);
  }

  @Get()
  findAll(@Query() query: ProductQueryDto, @CurrentUser() user: JwtPayload) {
    return this.productsService.findAll(user.shopId as string, query);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @CurrentUser() user: JwtPayload) {
    return this.productsService.findOne(id, user.shopId as string);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateProductDto: UpdateProductDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.productsService.update(id, user.shopId as string, updateProductDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() user: JwtPayload) {
    return this.productsService.remove(id, user.shopId as string);
  }

  @Post(':id/image')
  @UseInterceptors(FileInterceptor('file'))
  async uploadImage(
    @Param('id') id: string,
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: JwtPayload,
    @Inject('StorageProvider') storageProvider: StorageProvider,
  ) {
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    // Validate MIME type
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedMimeTypes.includes(file.mimetype)) {
      throw new BadRequestException('Invalid file type. Only JPEG, PNG, and WebP are allowed.');
    }

    // Validate file size (5MB max)
    const maxSize = 5 * 1024 * 1024;
    if (file.size > maxSize) {
      throw new BadRequestException('File size exceeds the 5MB limit.');
    }

    const currentProduct = await this.productsService.findOne(id, user.shopId as string);

    const ext = file.originalname.split('.').pop();
    const filePath = `product-images/${user.shopId}/${id}-${Date.now()}.${ext}`;
    
    const imageUrl = await storageProvider.replaceFile(
      currentProduct.imageUrl,
      filePath,
      file.buffer,
      file.mimetype,
    );

    return this.productsService.updateImage(id, user.shopId as string, imageUrl);
  }

  @Delete(':id/image')
  async deleteImage(
    @Param('id') id: string,
    @CurrentUser() user: JwtPayload,
    @Inject('StorageProvider') storageProvider: StorageProvider,
  ) {
    const currentProduct = await this.productsService.findOne(id, user.shopId as string);

    if (currentProduct.imageUrl) {
      await storageProvider.deleteFile(currentProduct.imageUrl);
      await this.productsService.updateImage(id, user.shopId as string, null);
    }

    return { message: 'Product image deleted successfully' };
  }

  @Post('bulk-import/preview')
  @UseInterceptors(FileInterceptor('file'))
  bulkImportPreview(
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.productsBulkService.previewImport(user.shopId as string, file.buffer);
  }

  @Post('bulk-import/confirm')
  @UseInterceptors(FileInterceptor('file'))
  bulkImportConfirm(
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.productsBulkService.confirmImport(user.shopId as string, file.buffer);
  }
}
