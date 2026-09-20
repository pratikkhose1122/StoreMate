import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { WhatsappService } from './whatsapp.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

class SendBillDto {
  phone: string;
  pdfBase64: string;
  invoiceNumber: string;
  amount: string;
  caption: string;
}

@Controller('whatsapp')
@UseGuards(JwtAuthGuard)
export class WhatsappController {
  constructor(private readonly whatsappService: WhatsappService) {}

  @Post('send-bill')
  async sendBill(@Body() sendBillDto: SendBillDto) {
    return this.whatsappService.sendBillDocument(
      sendBillDto.phone,
      sendBillDto.pdfBase64,
      sendBillDto.invoiceNumber,
      sendBillDto.amount,
      sendBillDto.caption
    );
  }
}
