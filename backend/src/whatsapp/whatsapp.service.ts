import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class WhatsappService {
  private readonly logger = new Logger(WhatsappService.name);
  private apiUrl: string;
  private apiKey: string;
  private sessionId: string;

  constructor(private configService: ConfigService) {
    this.apiUrl = this.configService.get<string>('OPENWA_API_URL') || 'http://localhost:2785';
    this.apiKey = this.configService.get<string>('OPENWA_API_KEY') || '';
    this.sessionId = this.configService.get<string>('OPENWA_SESSION_ID') || 'default';
  }

  async sendBillDocument(phone: string, pdfBase64: string, invoiceNumber: string, amount: string, caption: string): Promise<any> {
    try {
      // Clean phone number (remove +, spaces, dashes)
      let cleanPhone = phone.replace(/[^0-9]/g, '');
      
      // If it doesn't have a country code (length 10 in India), assume +91
      if (cleanPhone.length === 10) {
        cleanPhone = `91${cleanPhone}`;
      } else if (cleanPhone.startsWith('0') && cleanPhone.length === 11) {
        cleanPhone = `91${cleanPhone.substring(1)}`;
      }

      const chatId = `${cleanPhone}@c.us`;

      const response = await fetch(`${this.apiUrl}/api/sessions/${this.sessionId}/messages/send-document`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': this.apiKey,
        },
        body: JSON.stringify({
          chatId,
          base64: pdfBase64,
          fileName: `${invoiceNumber}.pdf`,
          mimetype: 'application/pdf',
          caption,
        }),
      });

      if (!response.ok) {
        const errorData = await response.text();
        this.logger.error(`OpenWA failed to send document: ${response.status} - ${errorData}`);
        throw new Error(`OpenWA API error: ${response.statusText}`);
      }
      
      const responseData = await response.json();
      this.logger.log(`OpenWA send-document response: ${JSON.stringify(responseData)}`);
      
      return responseData;
    } catch (error) {
      this.logger.error('Error sending WhatsApp bill', error);
      throw error;
    }
  }
}
