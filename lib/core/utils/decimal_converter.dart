import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class DecimalConverter implements JsonConverter<Decimal, dynamic> {
  const DecimalConverter();

  @override
  Decimal fromJson(dynamic json) {
    if (json == null) return Decimal.zero;
    if (json is String) return Decimal.tryParse(json) ?? Decimal.zero;
    if (json is num) return Decimal.parse(json.toString());
    return Decimal.zero;
  }

  @override
  dynamic toJson(Decimal object) {
    return object.toString();
  }
}

class NullableDecimalConverter implements JsonConverter<Decimal?, dynamic> {
  const NullableDecimalConverter();

  @override
  Decimal? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return Decimal.tryParse(json);
    if (json is num) return Decimal.parse(json.toString());
    return null;
  }

  @override
  dynamic toJson(Decimal? object) {
    return object?.toString();
  }
}
