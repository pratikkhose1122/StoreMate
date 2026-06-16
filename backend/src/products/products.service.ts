import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { Product } from './entities/product.entity';
import {
  CreateProductDto,
  UpdateProductDto,
  ProductQueryDto,
} from './dto/product.dto';
import { CategoriesService } from '../categories/categories.service';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    private readonly categoriesService: CategoriesService,
  ) {}

  async create(createProductDto: CreateProductDto, shopId: string): Promise<Product> {
    // 1. Verify barcode/SKU uniqueness within the shop
    await this.checkUniqueness(shopId, createProductDto.sku, createProductDto.barcode);

    // 2. Verify category exists if provided
    if (createProductDto.categoryId) {
      await this.categoriesService.findOne(createProductDto.categoryId, shopId);
    }

    const product = this.productRepository.create({
      ...createProductDto,
      shopId,
    });

    return this.productRepository.save(product);
  }

  async findAll(shopId: string, query: ProductQueryDto) {
    const { page = 1, limit = 20, search, categoryId } = query;
    const skip = (page - 1) * limit;

    const where: any = { shopId };

    if (search) {
      // Basic ILIKE search, the DB will use the pg_trgm GIN index
      where.name = ILike(`%${search}%`);
    }

    if (categoryId) {
      where.categoryId = categoryId;
    }

    const [items, total] = await this.productRepository.findAndCount({
      where,
      skip,
      take: limit,
      order: { createdAt: 'DESC' },
      relations: ['category'], // fetch category details too
    });

    return {
      items,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string, shopId: string): Promise<Product> {
    const product = await this.productRepository.findOne({
      where: { id, shopId },
      relations: ['category'],
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    return product;
  }

  async update(id: string, shopId: string, updateProductDto: UpdateProductDto): Promise<Product> {
    const product = await this.findOne(id, shopId);

    // Verify SKU/Barcode uniqueness if they are being updated
    if (
      (updateProductDto.sku && updateProductDto.sku !== product.sku) ||
      (updateProductDto.barcode && updateProductDto.barcode !== product.barcode)
    ) {
      await this.checkUniqueness(
        shopId,
        updateProductDto.sku === product.sku ? undefined : updateProductDto.sku,
        updateProductDto.barcode === product.barcode ? undefined : updateProductDto.barcode,
      );
    }

    // Verify new category if provided
    if (updateProductDto.categoryId) {
      await this.categoriesService.findOne(updateProductDto.categoryId, shopId);
    }

    Object.assign(product, updateProductDto);
    return this.productRepository.save(product);
  }

  async remove(id: string, shopId: string): Promise<void> {
    const product = await this.findOne(id, shopId);
    await this.productRepository.softRemove(product);
  }

  async updateImage(id: string, shopId: string, imageUrl: string | null): Promise<Product> {
    const product = await this.findOne(id, shopId);
    product.imageUrl = imageUrl ?? undefined;
    return this.productRepository.save(product);
  }

  /**
   * Helper to check SKU and Barcode uniqueness per shop
   */
  private async checkUniqueness(shopId: string, sku?: string | null, barcode?: string | null) {
    if (sku) {
      const existingSku = await this.productRepository.findOne({
        where: { shopId, sku },
      });
      if (existingSku) throw new ConflictException(`SKU '${sku}' already exists.`);
    }

    if (barcode) {
      const existingBarcode = await this.productRepository.findOne({
        where: { shopId, barcode },
      });
      if (existingBarcode) throw new ConflictException(`Barcode '${barcode}' already exists.`);
    }
  }
}
