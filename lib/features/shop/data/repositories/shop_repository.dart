import 'package:dio/dio.dart';
import 'package:storemate/core/network/dio_client.dart';
import 'package:storemate/core/constants/api_constants.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';

/// Repository for shop-related API operations.
class ShopRepository {
  final DioClient _client;

  ShopRepository(this._client);

  /// POST /shops
  ///
  /// Register a new shop for the authenticated user.
  /// Returns the created shop and a new JWT with shop_id.
  Future<({ShopModel shop, String accessToken})> createShop({
    required String name,
    required String ownerName,
    String? mobileNumber,
    String? email,
    String? address,
    required String businessType,
  }) async {
    final response = await _client.post(
      ApiConstants.shops,
      data: {
        'name': name,
        'ownerName': ownerName,
        if (mobileNumber != null && mobileNumber.isNotEmpty)
          'mobileNumber': mobileNumber,
        if (email != null && email.isNotEmpty) 'email': email,
        if (address != null && address.isNotEmpty) 'address': address,
        'businessType': businessType,
      },
    );

    // Unwrap the API response envelope
    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;

    final shop = ShopModel.fromJson(data['shop'] as Map<String, dynamic>);
    final accessToken = data['accessToken'] as String;

    return (shop: shop, accessToken: accessToken);
  }

  /// PUT /shops/settings
  Future<ShopModel> updateSettings(Map<String, dynamic> data) async {
    final response = await _client.put('${ApiConstants.shops}/settings', data: data);
    return ShopModel.fromJson(response.data['data']['shop']);
  }

  /// POST /shops/logo
  Future<String> uploadLogo(String filePath) async {
    final formData = FormData.fromMap({
      'logo': await MultipartFile.fromFile(filePath),
    });
    final response = await _client.post('${ApiConstants.shops}/logo', data: formData);
    return response.data['data']['logoUrl'];
  }

  /// DELETE /shops/logo
  Future<void> deleteLogo() async {
    await _client.delete('${ApiConstants.shops}/logo');
  }
}
