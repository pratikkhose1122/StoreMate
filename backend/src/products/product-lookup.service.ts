import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from './entities/product.entity';

@Injectable()
export class ProductLookupService {
  private readonly logger = new Logger(ProductLookupService.name);

  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  async getBarcodeProduct(barcode: string, shopId: string) {
    // 1. Search local DB
    const localProduct = await this.findByBarcode(barcode, shopId);
    if (localProduct) {
      return {
        source: 'local',
        product: localProduct,
      };
    }

    // 2. Fallback to Open Food Facts
    const offProduct = await this.fetchFromOpenFoodFacts(barcode);
    if (offProduct) {
      return {
        source: 'open_food_facts',
        product: offProduct,
      };
    }

    // 3. Not found anywhere
    return {
      source: 'manual_required',
      product: { barcode },
    };
  }

  private async findByBarcode(barcode: string, shopId: string): Promise<Product | null> {
    return this.productRepository.findOne({
      where: { barcode, shopId },
      relations: ['category'],
    });
  }

  private async fetchFromOpenFoodFacts(barcode: string): Promise<any | null> {
    try {
      const response = await fetch(`https://world.openfoodfacts.org/api/v0/product/${barcode}.json`);
      if (!response.ok) {
        this.logger.warn(`Open Food Facts API error: ${response.statusText}`);
        return null;
      }
      
      const data = await response.json();
      if (data.status === 1 && data.product) {
        const p = data.product;
        return {
          barcode,
          name: p.product_name || p.product_name_en || '',
          brand: p.brands || '',
          imageUrl: p.image_front_url || p.image_url || '',
          packageSize: p.quantity || '',
        };
      }
      return null;
    } catch (error) {
      this.logger.error('Failed to fetch from Open Food Facts', error);
      return null;
    }
  }
}
