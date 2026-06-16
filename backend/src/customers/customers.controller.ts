import { Controller, Get, Post, Body, Param, Put, Delete, UseGuards, Request, Query } from '@nestjs/common';
import { CustomersService, CreateCustomerDto, UpdateCustomerDto } from './customers.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('customers')
@UseGuards(JwtAuthGuard)
export class CustomersController {
  constructor(private readonly customersService: CustomersService) {}

  @Post()
  create(@Request() req: any, @Body() createCustomerDto: CreateCustomerDto) {
    return this.customersService.create(req.user.shopId, createCustomerDto);
  }

  @Get()
  findAll(@Request() req: any, @Query('q') query?: string) {
    return this.customersService.findAll(req.user.shopId, query);
  }

  @Get(':id')
  findOne(@Request() req: any, @Param('id') id: string) {
    return this.customersService.findOne(req.user.shopId, id);
  }

  @Put(':id')
  update(@Request() req: any, @Param('id') id: string, @Body() updateCustomerDto: UpdateCustomerDto) {
    return this.customersService.update(req.user.shopId, id, updateCustomerDto);
  }

  @Delete(':id')
  remove(@Request() req: any, @Param('id') id: string) {
    return this.customersService.remove(req.user.shopId, id);
  }
}
