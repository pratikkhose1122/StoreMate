import { Controller, Post, Body, Request, UseGuards, Get, Param, Query } from '@nestjs/common';
import { SalesService, CheckoutDto } from './sales.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('sales')
@UseGuards(JwtAuthGuard)
export class SalesController {
  constructor(private readonly salesService: SalesService) {}

  @Post('checkout')
  async checkout(@Request() req: any, @Body() checkoutDto: CheckoutDto) {
    const sale = await this.salesService.checkout(req.user.shopId, checkoutDto, req.user);
    return {
      message: 'Checkout successful',
      data: sale,
    };
  }

  @Get()
  async findAll(
    @Request() req: any,
    @Query('limit') limit = 20,
    @Query('offset') offset = 0,
    @Query('customerId') customerId?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    const result = await this.salesService.findAll(
      req.user.shopId,
      limit,
      offset,
      customerId,
      startDate,
      endDate,
    );
    return {
      data: result.data,
      total: result.total,
    };
  }

  @Get(':id')
  async findOne(@Request() req: any, @Param('id') id: string) {
    const sale = await this.salesService.findOne(req.user.shopId, id);
    return { data: sale };
  }
}
