import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';

abstract class InvoiceTemplateService {
  Future<Uint8List> generateInvoice(ShopModel shop, SaleModel sale);
}

class ClassicInvoiceTemplate implements InvoiceTemplateService {
  @override
  Future<Uint8List> generateInvoice(ShopModel shop, SaleModel sale) async {
    final pdf = pw.Document();

    final dateStr = sale.createdAt != null ? DateFormat.yMd().add_jm().format(sale.createdAt!) : '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(shop.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      if (shop.address != null) pw.Text(shop.address!),
                      if (shop.mobileNumber != null) pw.Text('Phone: ${shop.mobileNumber}'),
                      if (shop.gstNumber != null) pw.Text('GSTIN: ${shop.gstNumber}'),
                    ],
                  ),
                  pw.BarcodeWidget(
                    data: 'INV:${sale.invoiceNumber}|SHOP:${shop.shopCode}|SALE:${sale.id}',
                    barcode: pw.Barcode.qrCode(),
                    width: 80,
                    height: 80,
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // Invoice Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INVOICE TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(sale.customer?.name ?? 'Walk-in Customer'),
                      if (sale.customer?.mobileNumber != null) pw.Text(sale.customer!.mobileNumber!),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Invoice #: ${sale.invoiceNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: $dateStr'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  // Table Rows
                  ...sale.items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.productName)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${item.unitPrice.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rs. ${item.subtotal.toStringAsFixed(2)}', textAlign: pw.TextAlign.right)),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Amount: Rs. ${sale.totalAmount.toStringAsFixed(2)}'),
                      if (sale.discountAmount > 0) pw.Text('Discount: -Rs. ${sale.discountAmount.toStringAsFixed(2)}'),
                      if (sale.taxAmount > 0) pw.Text('Tax: +Rs. ${sale.taxAmount.toStringAsFixed(2)}'),
                      pw.Divider(),
                      pw.Text('Net Amount: Rs. ${sale.netAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Text('Amount Paid: Rs. ${sale.amountPaid.toStringAsFixed(2)}'),
                      if (sale.amountDue > 0)
                        pw.Text('Amount Due: Rs. ${sale.amountDue.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.red)),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(child: pw.Text('Thank you for your business!', style: pw.TextStyle(color: PdfColors.grey600))),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
