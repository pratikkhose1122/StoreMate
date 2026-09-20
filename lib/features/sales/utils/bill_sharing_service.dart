import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';
import 'package:storemate/features/sales/utils/invoice_template_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:storemate/core/network/dio_client.dart';

class BillSharingService {
  final DioClient _dioClient;

  BillSharingService(this._dioClient);

  /// Generates the PDF and sends it to the StoreMate backend which
  /// automatically delivers it to the customer's WhatsApp via the WhatsApp HTTP API.
  /// 
  /// If [phoneNumber] is empty, falls back to the native share sheet.
  Future<void> shareBill(
    BuildContext context,
    SaleModel sale,
    ShopModel shop,
    {String? phoneNumber}
  ) async {
    try {
      // 1. Generate Invoice PDF using existing template
      final invoiceService = ClassicInvoiceTemplate();
      final pdfBytes = await invoiceService.generateInvoice(shop, sale);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Invoice_${sale.invoiceNumber}.pdf');
      await file.writeAsBytes(pdfBytes);

      final customerName = sale.customer?.name;
      final dateStr = sale.createdAt != null ? DateFormat('dd MMM yyyy').format(sale.createdAt!) : '';
      
      final StringBuffer messageBuffer = StringBuffer();
      
      if (customerName != null && customerName.isNotEmpty) {
        messageBuffer.writeln('Hello $customerName,');
      } else {
        messageBuffer.writeln('Hello,');
      }
      
      messageBuffer.writeln('\nThank you for shopping at ${shop.name}.\n');
      messageBuffer.writeln('Invoice: ${sale.invoiceNumber}');
      messageBuffer.writeln('Date: $dateStr');
      messageBuffer.writeln('Amount: ₹${sale.totalAmount.toStringAsFixed(2)}\n');
      messageBuffer.writeln('Please find your invoice attached.');

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // 2. Share via WhatsApp via StoreMate Backend API
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sending bill to WhatsApp...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        final pdfBase64 = base64Encode(pdfBytes);
        
        try {
          await _dioClient.post(
            '/whatsapp/send-bill',
            data: {
              'phone': phoneNumber,
              'pdfBase64': pdfBase64,
              'invoiceNumber': sale.invoiceNumber,
              'amount': sale.totalAmount.toString(),
              'caption': messageBuffer.toString(),
            },
          );
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invoice sent to WhatsApp successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (apiError) {
          debugPrint('Backend WhatsApp sending failed: $apiError');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sale completed, but WhatsApp delivery failed. Retry sending.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        // 3. Open share sheet if no phone number
        final xFile = XFile(file.path, mimeType: 'application/pdf');
        await Share.shareXFiles(
          [xFile],
          text: messageBuffer.toString(),
          subject: 'Invoice ${sale.invoiceNumber}',
        );
      }
    } catch (e) {
      debugPrint('BillSharingService error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share the bill. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
