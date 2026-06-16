import { Controller, Get, Query, UseGuards, Header, BadRequestException } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from '../auth/decorators/current-user.decorator';

@Controller('reports')
@UseGuards(JwtAuthGuard)
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  private getShopId(user: JwtPayload): string {
    if (!user.shopId) throw new BadRequestException('No shop found for user');
    return user.shopId;
  }

  @Get('sales')
  async getSales(
    @CurrentUser() user: JwtPayload,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    return this.reportsService.getSalesData(this.getShopId(user), startDate, endDate);
  }

  @Get('profit')
  async getProfit(
    @CurrentUser() user: JwtPayload,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    return this.reportsService.getProfitData(this.getShopId(user), startDate, endDate);
  }

  @Get('top-products')
  async getTopProducts(@CurrentUser() user: JwtPayload) {
    return this.reportsService.getTopProducts(this.getShopId(user));
  }

  @Get('slow-products')
  async getSlowProducts(@CurrentUser() user: JwtPayload) {
    return this.reportsService.getSlowProducts(this.getShopId(user));
  }

  // Exports
  @Get('export/products')
  @Header('Content-Disposition', 'attachment; filename="products.csv"')
  async exportProducts(@CurrentUser() user: JwtPayload) {
    return this.reportsService.exportProducts(this.getShopId(user));
  }

  @Get('export/customers')
  @Header('Content-Disposition', 'attachment; filename="customers.csv"')
  async exportCustomers(@CurrentUser() user: JwtPayload) {
    return this.reportsService.exportCustomers(this.getShopId(user));
  }

  @Get('export/sales')
  @Header('Content-Disposition', 'attachment; filename="sales.csv"')
  async exportSales(@CurrentUser() user: JwtPayload) {
    return this.reportsService.exportSales(this.getShopId(user));
  }

  @Get('export/inventory-logs')
  @Header('Content-Disposition', 'attachment; filename="inventory-logs.csv"')
  async exportInventoryLogs(@CurrentUser() user: JwtPayload) {
    return this.reportsService.exportInventoryLogs(this.getShopId(user));
  }
}
