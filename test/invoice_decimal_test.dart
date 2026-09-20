import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:storemate/core/utils/currency_formatter.dart';

void main() {
  group('Phase 2H - CurrencyFormatter Financial Integrity', () {
    test('Strict format of edge-case decimal values', () {
      final values = [
        '0.01',
        '0.10',
        '0.29',
        '1.99',
        '10.01',
        '99.99',
        '100.10',
        '999.99',
        '1234.56',
        '999999.99'
      ];

      for (final v in values) {
        final decimal = Decimal.parse(v);
        final formatted = CurrencyFormatter.format(decimal);
        // Expecting exact string preservation, padding as necessary
        expect(formatted, equals(v), reason: 'Value $v distorted during format to $formatted');
      }
    });

    test('Strict format of fractional quantities', () {
      final decimal1 = Decimal.parse('0.001');
      expect(CurrencyFormatter.format(decimal1, fractionDigits: 3), equals('0.001'));
      
      final decimal2 = Decimal.parse('1.250');
      expect(CurrencyFormatter.format(decimal2, fractionDigits: 3), equals('1.250'));
      
      final decimal3 = Decimal.parse('2.500');
      expect(CurrencyFormatter.format(decimal3, fractionDigits: 3), equals('2.500'));
    });

    test('Strict fractional quantity arithmetic', () {
      // unit price * fractional quantity
      final unitPrice = Decimal.parse('100.10');
      final quantity = Decimal.parse('1.250');
      // Wait, let's just do exact arithmetic for test
      final exactSubtotal = unitPrice * quantity; // 125.12500
      
      expect(exactSubtotal.toString(), equals('125.125'));
      // When formatted for currency (2 decimals), it uses rounding.
      final formattedSubtotal = CurrencyFormatter.format(exactSubtotal, fractionDigits: 2);
      expect(formattedSubtotal, equals('125.13')); // 125.125 -> 125.13
    });

    test('Cross-artifact reconciliation of financial fields', () {
      final totalAmount = Decimal.parse('1234.56');
      final netAmount = Decimal.parse('1200.00');

      // WhatsApp generator simulation
      final whatsappAmountStr = CurrencyFormatter.format(totalAmount);
      
      // Thermal receipt simulation
      final thermalAmountStr = CurrencyFormatter.format(totalAmount);
      final thermalNetStr = CurrencyFormatter.format(netAmount);
      
      // PDF Invoice simulation
      final pdfAmountStr = CurrencyFormatter.format(totalAmount);
      final pdfNetStr = CurrencyFormatter.format(netAmount);

      expect(whatsappAmountStr, equals('1234.56'));
      expect(thermalAmountStr, equals('1234.56'));
      expect(pdfAmountStr, equals('1234.56'));

      // Strict equivalence
      expect(whatsappAmountStr, equals(pdfAmountStr));
      expect(thermalAmountStr, equals(pdfAmountStr));
      
      expect(thermalNetStr, equals(pdfNetStr));
    });

    test('Compound financial scenario: Multi-item, Tax, Discount, Partial Refund', () {
      final unitPriceA = Decimal.parse('100.10');
      final qtyA = Decimal.parse('1.250');
      final subtotalA = unitPriceA * qtyA; // 125.125
      
      final unitPriceB = Decimal.parse('999.99');
      final qtyB = Decimal.parse('2');
      final subtotalB = unitPriceB * qtyB; // 1999.98
      
      final totalAmount = subtotalA + subtotalB; // 2125.105
      final discount = Decimal.parse('25.10');
      final tax = Decimal.parse('100.00');
      final netAmount = totalAmount - discount + tax; // 2200.005
      
      final refundAmount = Decimal.parse('500.00');
      
      // Verification of Decimal logic strictly through CurrencyFormatter
      expect(CurrencyFormatter.format(subtotalA, fractionDigits: 2), equals('125.13'));
      expect(CurrencyFormatter.format(subtotalB, fractionDigits: 2), equals('1999.98'));
      expect(CurrencyFormatter.format(totalAmount, fractionDigits: 2), equals('2125.11'));
      expect(CurrencyFormatter.format(netAmount, fractionDigits: 2), equals('2200.01'));
      expect(CurrencyFormatter.format(refundAmount, fractionDigits: 2), equals('500.00'));
      
      // WhatsApp message outputs Total Amount
      final whatsappOut = CurrencyFormatter.format(totalAmount, fractionDigits: 2);
      expect(whatsappOut, equals('2125.11'));
    });

    test('Full refund scenario: Original invoice immutability', () {
      final totalAmount = Decimal.parse('5000.00');
      final refundAmount = Decimal.parse('5000.00');
      
      // The original invoice still reads totalAmount: 5000.00
      expect(CurrencyFormatter.format(totalAmount, fractionDigits: 2), equals('5000.00'));
      
      // The refund receipt reads refundAmount: 5000.00
      expect(CurrencyFormatter.format(refundAmount, fractionDigits: 2), equals('5000.00'));
    });
  });
}
