import {
  Controller,
  Post,
  Body,
  UseGuards,
  Get,
  Query,
  Param,
} from '@nestjs/common';
import { InventoryService } from './inventory.service';
import { AdjustInventoryDto } from './dto/inventory.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser, JwtPayload } from '../auth/decorators/current-user.decorator';

@Controller('inventory')
@UseGuards(JwtAuthGuard)
export class InventoryController {
  constructor(private readonly inventoryService: InventoryService) {}

  @Post('adjust')
  adjust(
    @Body() adjustInventoryDto: AdjustInventoryDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.inventoryService.adjust(
      adjustInventoryDto,
      user.shopId as string,
      user.sub,
    );
  }

  @Get('logs')
  getLogs(
    @Query('productId') productId: string,
    @Query('limit') limit: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.inventoryService.getLogs(
      user.shopId as string,
      productId,
      limit ? parseInt(limit, 10) : 50,
    );
  }

  @Get('history/:productId')
  getHistory(
    @Param('productId') productId: string,
    @Query('page') page: string,
    @Query('limit') limit: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.inventoryService.getHistory(
      user.shopId as string,
      productId,
      page ? parseInt(page, 10) : 1,
      limit ? parseInt(limit, 10) : 20,
    );
  }
}
