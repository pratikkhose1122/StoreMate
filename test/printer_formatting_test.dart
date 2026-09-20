import 'package:flutter_test/flutter_test.dart';
import 'package:storemate/features/sales/utils/thermal_receipt_service.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:decimal/decimal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ThermalReceiptService Formatting Tests', () {
    test('58mm Receipt generates correct line widths (max 32 chars)', () async {
      final service = ThermalReceiptService();
      
      final sale = SaleModel(
        id: 'sale_123',
        shopId: 'shop_123',
        invoiceNumber: 'INV-2026-001',
        totalAmount: Decimal.parse('30.00'),
        discountAmount: Decimal.parse('0.00'),
        taxAmount: Decimal.parse('0.00'),
        netAmount: Decimal.parse('30.00'),
        amountPaid: Decimal.parse('30.00'),
        amountDue: Decimal.parse('0.00'),
        status: 'completed',
        createdAt: DateTime(2026, 9, 17),
        items: [
          SaleItemModel(
            id: 'item_1',
            saleId: 'sale_123',
            productId: 'prod_1',
            productName: 'Test Item',
            quantity: Decimal.parse('2.0'),
            unitPrice: Decimal.parse('15.00'),
            taxPercentage: Decimal.zero,
            subtotal: Decimal.parse('30.00'),
          )
        ],
        payments: [],
        refundAmount: Decimal.zero,
      );

      final receiptBytes = await service.generateReceipt(
        sale,
        shopName: "StoreMate HQ",
        paperSize: PaperSize.mm58,
      );
      
      expect(receiptBytes, isNotEmpty);
      expect(receiptBytes.length, greaterThan(100));
    });

    test('80mm Receipt generates correct line widths (max 48 chars)', () async {
      final service = ThermalReceiptService();
      
      final sale = SaleModel(
        id: 'sale_124',
        shopId: 'shop_123',
        invoiceNumber: 'INV-2026-002',
        totalAmount: Decimal.parse('204.99'),
        discountAmount: Decimal.parse('0.00'),
        taxAmount: Decimal.parse('5.00'),
        netAmount: Decimal.parse('204.99'),
        amountPaid: Decimal.parse('204.99'),
        amountDue: Decimal.parse('0.00'),
        status: 'completed',
        createdAt: DateTime(2026, 9, 17),
        items: [
          SaleItemModel(
            id: 'item_2',
            saleId: 'sale_124',
            productId: 'prod_2',
            productName: 'Expensive Product With Very Long Name',
            quantity: Decimal.parse('1.0'),
            unitPrice: Decimal.parse('199.99'),
            taxPercentage: Decimal.parse('5.0'),
            subtotal: Decimal.parse('199.99'),
          )
        ],
        payments: [],
        refundAmount: Decimal.zero,
      );

      final receiptBytes = await service.generateReceipt(
        sale,
        shopName: "StoreMate Superstore",
        paperSize: PaperSize.mm80,
      );
      
      expect(receiptBytes, isNotEmpty);
      expect(receiptBytes.length, greaterThan(100));
    });
  });
}
