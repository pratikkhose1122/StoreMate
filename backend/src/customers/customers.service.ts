import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Customer } from './entities/customer.entity';

export class CreateCustomerDto {
  name: string;
  mobileNumber?: string;
  email?: string;
  address?: string;
}

export class UpdateCustomerDto extends CreateCustomerDto {}

@Injectable()
export class CustomersService {
  constructor(
    @InjectRepository(Customer)
    private readonly customerRepository: Repository<Customer>,
  ) {}

  async create(shopId: string, createCustomerDto: CreateCustomerDto): Promise<Customer> {
    const customer = this.customerRepository.create({
      shopId,
      ...createCustomerDto,
    });
    return this.customerRepository.save(customer);
  }

  async findAll(shopId: string, query?: string): Promise<Customer[]> {
    const qb = this.customerRepository.createQueryBuilder('customer')
      .where('customer.shopId = :shopId', { shopId });

    if (query) {
      qb.andWhere('(customer.name ILIKE :query OR customer.mobileNumber ILIKE :query)', { query: `%${query}%` });
    }

    qb.orderBy('customer.name', 'ASC');

    return qb.getMany();
  }

  async findOne(shopId: string, id: string): Promise<Customer> {
    const customer = await this.customerRepository.findOne({ where: { shopId, id } });
    if (!customer) {
      throw new NotFoundException(`Customer #${id} not found`);
    }
    return customer;
  }

  async update(shopId: string, id: string, updateCustomerDto: UpdateCustomerDto): Promise<Customer> {
    const customer = await this.findOne(shopId, id);
    Object.assign(customer, updateCustomerDto);
    return this.customerRepository.save(customer);
  }

  async remove(shopId: string, id: string): Promise<void> {
    const customer = await this.findOne(shopId, id);
    await this.customerRepository.softRemove(customer);
  }
}
