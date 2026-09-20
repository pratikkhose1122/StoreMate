import 'package:decimal/decimal.dart';

/// A centralized formatting utility to format financial Decimal values
/// strictly without passing through lossy floating-point [double] types.
class CurrencyFormatter {
  /// Formats a Decimal value strictly to a currency string with a given number of fractional digits.
  /// Defaults to 2 fractional digits.
  static String format(Decimal value, {int fractionDigits = 2}) {
    return value.toStringAsFixed(fractionDigits);
  }
}
