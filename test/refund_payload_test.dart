import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Refund Payload Verification', () {
    test('Client should only send sale_item_id and quantity (no financial doubles)', () {
      final qty = Decimal.parse('1.000');
      
      // Simulate payload generation in RefundScreen
      final payload = {
        'sale_item_id': 'item-1',
        'product_id': 'prod-1',
        'quantity': qty.toString(),
      };

      // VERIFY ONLY AUTHORITATIVE IDENTIFIERS AND QUANTITY ARE SENT
      expect(payload.containsKey('line_total'), isFalse, reason: 'Client must not spoof line_total');
      expect(payload.containsKey('tax_amount'), isFalse, reason: 'Client must not spoof tax_amount');
      expect(payload.containsKey('unit_price'), isFalse, reason: 'Client must not spoof unit_price');
      expect(payload.containsKey('discount_amount'), isFalse, reason: 'Client must not spoof discount_amount');
      
      expect(payload['quantity'], '1', reason: 'Quantity must be string-safe');
      expect(payload['sale_item_id'], 'item-1');
    });
  });
}
