import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import '../../../../core/utils/currency_formatter.dart';

final thermalReceiptServiceProvider = Provider<ThermalReceiptService>((ref) {
  return ThermalReceiptService();
});

class ThermalReceiptService {
  Future<List<int>> generateReceipt(SaleModel sale, {
    required PaperSize paperSize,
    required String shopName,
    String? gstNumber,
    String? footerMessage,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(shopName,
        styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2, bold: true));
    
    if (gstNumber != null && gstNumber.isNotEmpty) {
      bytes += generator.text('GST: $gstNumber', styles: const PosStyles(align: PosAlign.center));
    }
    
    bytes += generator.feed(1);
    final dateStr = sale.createdAt != null ? DateFormat('dd-MMM-yyyy hh:mm a').format(sale.createdAt!) : '';
    bytes += generator.text('Date: $dateStr', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Inv No: ${sale.invoiceNumber}', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(1);

    // Separator
    bytes += generator.hr();

    // Column Headers
    if (paperSize == PaperSize.mm80) {
      bytes += generator.row([
        PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(text: 'Qty', width: 2, styles: const PosStyles(bold: true, align: PosAlign.center)),
        PosColumn(text: 'Rate', width: 2, styles: const PosStyles(bold: true, align: PosAlign.right)),
        PosColumn(text: 'Total', width: 2, styles: const PosStyles(bold: true, align: PosAlign.right)),
      ]);
    } else {
      bytes += generator.row([
        PosColumn(text: 'Item', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(text: 'Qty', width: 2, styles: const PosStyles(bold: true, align: PosAlign.center)),
        PosColumn(text: 'Total', width: 4, styles: const PosStyles(bold: true, align: PosAlign.right)),
      ]);
    }
    bytes += generator.hr();

    // Items
    for (var item in sale.items) {
      if (paperSize == PaperSize.mm80) {
        bytes += generator.row([
          PosColumn(text: item.productName, width: 6),
          PosColumn(text: '${item.quantity}', width: 2, styles: const PosStyles(align: PosAlign.center)),
          PosColumn(text: CurrencyFormatter.format(item.unitPrice), width: 2, styles: const PosStyles(align: PosAlign.right)),
          PosColumn(text: CurrencyFormatter.format(item.subtotal), width: 2, styles: const PosStyles(align: PosAlign.right)),
        ]);
      } else {
        bytes += generator.text(item.productName);
        bytes += generator.row([
          PosColumn(text: '', width: 2),
          PosColumn(text: '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}', width: 6),
          PosColumn(text: CurrencyFormatter.format(item.subtotal), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
    }

    bytes += generator.hr();

    // Totals
    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(text: CurrencyFormatter.format(sale.totalAmount), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);

    if (sale.discountAmount > Decimal.zero) {
      bytes += generator.row([
        PosColumn(text: 'Discount', width: 6),
        PosColumn(text: '-${CurrencyFormatter.format(sale.discountAmount)}', width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    if (sale.taxAmount > Decimal.zero) {
      bytes += generator.row([
        PosColumn(text: 'Tax', width: 6),
        PosColumn(text: CurrencyFormatter.format(sale.taxAmount), width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true, height: PosTextSize.size2, width: PosTextSize.size2)),
      PosColumn(text: 'Rs ${CurrencyFormatter.format(sale.netAmount)}', width: 6, styles: const PosStyles(bold: true, align: PosAlign.right, height: PosTextSize.size2, width: PosTextSize.size2)),
    ]);
    bytes += generator.feed(1);

    // Payment Method
    final paymentMethod = sale.payments.isNotEmpty ? sale.payments.first.paymentMethod : 'Unknown';
    bytes += generator.text('Payment: $paymentMethod', styles: const PosStyles(align: PosAlign.center));
    
    // Footer
    bytes += generator.feed(1);
    if (footerMessage != null && footerMessage.isNotEmpty) {
      bytes += generator.text(footerMessage, styles: const PosStyles(align: PosAlign.center));
    } else {
      bytes += generator.text('Thank You! Visit Again.', styles: const PosStyles(align: PosAlign.center));
    }

    bytes += generator.feed(2);
    bytes += generator.cut();
    
    return bytes;
  }

  Future<List<int>> generateTestReceipt(PaperSize paperSize) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    bytes += generator.text('PRINTER TEST',
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.feed(1);
    bytes += generator.text('Paper size: ${paperSize == PaperSize.mm80 ? '80mm' : '58mm'}', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);
    bytes += generator.text('If you can read this, your printer is configured correctly.', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();
    
    return bytes;
  }
}
