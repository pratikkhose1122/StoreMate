import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storemate/features/sales/data/models/hold_cart_model.dart';

class HoldCartRepository {
  static const String _boxName = 'hold_carts';

  Future<Box<String>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return await Hive.openBox<String>(_boxName);
  }

  Future<List<HoldCartModel>> getHoldCarts() async {
    final box = await _getBox();
    final carts = <HoldCartModel>[];
    
    for (var key in box.keys) {
      final jsonStr = box.get(key);
      if (jsonStr != null) {
        carts.add(HoldCartModel.fromJson(jsonDecode(jsonStr)));
      }
    }
    
    // Sort newest first
    carts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return carts;
  }

  Future<void> saveHoldCart(HoldCartModel cart) async {
    final box = await _getBox();
    await box.put(cart.id, jsonEncode(cart.toJson()));
  }

  Future<void> deleteHoldCart(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
