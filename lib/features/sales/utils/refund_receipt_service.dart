import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:storemate/features/sales/data/models/return_model.dart';
import 'package:printing/printing.dart';
import 'package:decimal/decimal.dart';
import '../../../../core/utils/currency_formatter.dart';

class RefundReceiptService {
  Future<Uint8List> generateRefundReceipt(ShopModel shop, SaleModel sale, ReturnModel returnRecord) async {
    final pdf = pw.Document();
    
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final dateStr = returnRecord.createdAt != null ? DateFormat('dd/MM/yyyy hh:mm a').format(returnRecord.createdAt!) : '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(shop.name, style: pw.TextStyle(font: fontBold, fontSize: 18), textAlign: pw.TextAlign.center),
              if (shop.mobileNumber != null) 
                pw.Text('Ph: ${shop.mobileNumber}', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
              pw.SizedBox(height: 5),
              pw.Text('REFUND RECEIPT', style: pw.TextStyle(font: fontBold, fontSize: 14)),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Refund No: ${returnRecord.refundNumber}', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    pw.Text('Original Invoice: ${sale.invoiceNumber}', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    pw.Text('Date: $dateStr', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                    if (returnRecord.reason != null)
                      pw.Text('Reason: ${returnRecord.reason}', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  ],
                ),
              ),
              
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              
              // Header
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text('Item', style: pw.TextStyle(font: fontBold, fontSize: 10))),
                  pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
                  pw.Expanded(flex: 2, child: pw.Text('Amount', style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.SizedBox(height: 4),
              
              // Items
              ...returnRecord.items.map((item) {
                final saleItem = sale.items.firstWhere(
                  (si) => si.id == item.saleItemId, 
                  orElse: () => SaleItemModel(
                    id: '', saleId: '', productName: 'Unknown', quantity: Decimal.zero, unitPrice: Decimal.zero, taxPercentage: Decimal.zero, subtotal: Decimal.zero
                  ),
                );
                
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(saleItem.productName, style: pw.TextStyle(font: fontRegular, fontSize: 10))
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('${item.quantity}', style: pw.TextStyle(font: fontRegular, fontSize: 10), textAlign: pw.TextAlign.center)
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('₹${CurrencyFormatter.format(item.lineTotal)}', style: pw.TextStyle(font: fontRegular, fontSize: 10), textAlign: pw.TextAlign.right)
                      ),
                    ]
                  ),
                );
              }),
              
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('REFUND AMOUNT', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                  pw.Text('₹${CurrencyFormatter.format(returnRecord.refundAmount)}', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Refund Method:', style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                  pw.Text(returnRecord.refundMethod.toUpperCase(), style: pw.TextStyle(font: fontRegular, fontSize: 10)),
                ],
              ),
              pw.Text('Refund Processed Successfully.', style: pw.TextStyle(font: fontRegular, fontSize: 10), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 10),
              
              // QR Code
              pw.BarcodeWidget(
                data: 'Refund: ${returnRecord.refundNumber} | Sale: ${sale.invoiceNumber} | Shop: ${shop.name} | Date: $dateStr',
                barcode: pw.Barcode.qrCode(),
                width: 60,
                height: 60,
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
