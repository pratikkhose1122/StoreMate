import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { parse } from 'csv-parse';
import { Product } from './entities/product.entity';
import { Category } from '../categories/entities/category.entity';
import { CategoriesService } from '../categories/categories.service';

interface CsvRow {
  name: string;
  sku?: string;
  barcode?: string;
  category?: string;
  purchase_price: string;
  selling_price: string;
  quantity: string;
  unit_type?: string;
}

export interface BulkImportPreview {
  validRows: any[];
  invalidRows: any[];
  warnings: string[];
}

@Injectable()
export class ProductsBulkService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
    private readonly categoriesService: CategoriesService,
    private readonly dataSource: DataSource,
  ) {}

  async parseCsvFile(buffer: Buffer): Promise<CsvRow[]> {
    return new Promise((resolve, reject) => {
      parse(buffer, { columns: true, skip_empty_lines: true, trim: true }, (err, records: unknown[]) => {
        if (err) return reject(new BadRequestException('Failed to parse CSV file'));
        resolve(records as CsvRow[]);
      });
    });
  }

  async previewImport(shopId: string, fileBuffer: Buffer): Promise<BulkImportPreview> {
    const records = await this.parseCsvFile(fileBuffer);
    
    const validRows: any[] = [];
    const invalidRows: any[] = [];
    const warnings: string[] = [];

    // Fetch existing SKUs, Barcodes, Categories
    const existingProducts = await this.productRepository.find({ where: { shopId }, select: ['sku', 'barcode'] });
    const existingSkus = new Set(existingProducts.map(p => p.sku).filter(Boolean));
    const existingBarcodes = new Set(existingProducts.map(p => p.barcode).filter(Boolean));

    records.forEach((row, index) => {
      const rowNum = index + 2; // +1 for 0-index, +1 for header
      const errors = [];

      if (!row.name) errors.push('Missing name');
      if (!row.purchase_price || isNaN(parseFloat(row.purchase_price))) errors.push('Invalid purchase_price');
      if (!row.selling_price || isNaN(parseFloat(row.selling_price))) errors.push('Invalid selling_price');
      if (!row.quantity || isNaN(parseInt(row.quantity, 10))) errors.push('Invalid quantity');

      if (row.sku && existingSkus.has(row.sku)) errors.push(`SKU '${row.sku}' already exists`);
      if (row.barcode && existingBarcodes.has(row.barcode)) errors.push(`Barcode '${row.barcode}' already exists`);

      if (errors.length > 0) {
        invalidRows.push({ rowNum, row, errors });
      } else {
        if (row.category) warnings.push(`Category '${row.category}' will be auto-created if it doesn't exist.`);
        
        validRows.push({
          rowNum,
          name: row.name,
          sku: row.sku || null,
          barcode: row.barcode || null,
          categoryName: row.category || null,
          purchasePrice: parseFloat(row.purchase_price),
          sellingPrice: parseFloat(row.selling_price),
          quantity: parseInt(row.quantity, 10),
          unitType: row.unit_type || 'piece',
        });

        // Add to existing sets to prevent duplicates WITHIN the CSV itself
        if (row.sku) existingSkus.add(row.sku);
        if (row.barcode) existingBarcodes.add(row.barcode);
      }
    });

    return { validRows, invalidRows, warnings: [...new Set(warnings)] };
  }

  async confirmImport(shopId: string, fileBuffer: Buffer) {
    const preview = await this.previewImport(shopId, fileBuffer);
    if (preview.validRows.length === 0) {
      throw new BadRequestException('No valid rows found to import.');
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    let importedCount = 0;

    try {
      // Pre-fetch categories
      const existingCategories = await queryRunner.manager.find(Category, { where: { shopId } });
      const categoryMap = new Map<string, string>();
      existingCategories.forEach(c => categoryMap.set(c.name.toLowerCase(), c.id));

      for (const row of preview.validRows) {
        let categoryId = null;

        if (row.categoryName) {
          const catKey = row.categoryName.toLowerCase();
          if (categoryMap.has(catKey)) {
            categoryId = categoryMap.get(catKey);
          } else {
            // Auto-create category
            const newCategory = queryRunner.manager.create(Category, {
              shopId,
              name: row.categoryName,
            });
            const savedCategory = await queryRunner.manager.save(Category, newCategory);
            categoryId = savedCategory.id;
            categoryMap.set(catKey, categoryId);
          }
        }

        const productData: any = {
          shopId,
          name: row.name,
          sku: row.sku || undefined,
          barcode: row.barcode || undefined,
          purchasePrice: row.purchasePrice,
          sellingPrice: row.sellingPrice,
          quantity: row.quantity,
          unitType: row.unitType,
        };

        if (categoryId) {
          productData.categoryId = categoryId;
        }

        const product = queryRunner.manager.create(Product, productData);

        await queryRunner.manager.save(Product, product);
        importedCount++;
      }

      await queryRunner.commitTransaction();
      return { success: true, imported: importedCount, failed: preview.invalidRows.length };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw new BadRequestException(`Import failed: ${error.message}`);
    } finally {
      await queryRunner.release();
    }
  }
}
