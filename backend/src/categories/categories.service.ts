import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from './entities/category.entity';
import { CreateCategoryDto, UpdateCategoryDto } from './dto/category.dto';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
  ) {}

  async create(createCategoryDto: CreateCategoryDto, shopId: string): Promise<Category> {
    const existing = await this.categoryRepository.findOne({
      where: { shopId, name: createCategoryDto.name },
    });

    if (existing) {
      throw new ConflictException(`Category '${createCategoryDto.name}' already exists.`);
    }

    const category = this.categoryRepository.create({
      ...createCategoryDto,
      shopId,
    });

    return this.categoryRepository.save(category);
  }

  async findAll(shopId: string): Promise<Category[]> {
    return this.categoryRepository.find({
      where: { shopId },
      order: { name: 'ASC' },
    });
  }

  async findOne(id: string, shopId: string): Promise<Category> {
    const category = await this.categoryRepository.findOne({
      where: { id, shopId },
    });

    if (!category) {
      throw new NotFoundException('Category not found');
    }

    return category;
  }

  async update(id: string, shopId: string, updateCategoryDto: UpdateCategoryDto): Promise<Category> {
    const category = await this.findOne(id, shopId);

    if (updateCategoryDto.name && updateCategoryDto.name !== category.name) {
      const existing = await this.categoryRepository.findOne({
        where: { shopId, name: updateCategoryDto.name },
      });
      if (existing) {
        throw new ConflictException(`Category '${updateCategoryDto.name}' already exists.`);
      }
    }

    Object.assign(category, updateCategoryDto);
    return this.categoryRepository.save(category);
  }

  async remove(id: string, shopId: string): Promise<void> {
    const category = await this.findOne(id, shopId);
    // Soft delete
    await this.categoryRepository.softRemove(category);
  }
}
