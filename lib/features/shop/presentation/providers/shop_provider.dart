import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:storemate/features/auth/data/repositories/auth_repository.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';
import 'package:storemate/features/shop/data/repositories/shop_repository.dart';

/// Provider for [ShopRepository].
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(
    ref.watch(dioClientProvider),
    ref.watch(secureStorageProvider),
  );
});

/// State for shop registration.
class ShopRegistrationState {
  final bool isLoading;
  final ShopModel? shop;
  final String? errorMessage;
  final bool isSuccess;

  const ShopRegistrationState({
    this.isLoading = false,
    this.shop,
    this.errorMessage,
    this.isSuccess = false,
  });

  ShopRegistrationState copyWith({
    bool? isLoading,
    ShopModel? shop,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ShopRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      shop: shop ?? this.shop,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Provider for shop registration state.
final shopRegistrationProvider =
    StateNotifierProvider<ShopRegistrationNotifier, ShopRegistrationState>(
  (ref) {
    return ShopRegistrationNotifier(
      ref.watch(shopRepositoryProvider),
      ref.watch(authRepositoryProvider),
      ref.read(authProvider.notifier),
    );
  },
);

/// StateNotifier for shop registration form submission.
class ShopRegistrationNotifier extends StateNotifier<ShopRegistrationState> {
  final ShopRepository _shopRepository;
  final AuthRepository _authRepository;
  final AuthNotifier _authNotifier;

  ShopRegistrationNotifier(
    this._shopRepository,
    this._authRepository,
    this._authNotifier,
  ) : super(const ShopRegistrationState());

  /// Submit the shop registration form.
  Future<void> registerShop({
    required String name,
    required String ownerName,
    String? mobileNumber,
    String? email,
    String? address,
    String? gstNumber,
    required String businessType,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final shop = await _shopRepository.createShop(
        name: name,
        ownerName: ownerName,
        mobileNumber: mobileNumber,
        email: email,
        address: address,
        gstNumber: gstNumber,
        businessType: businessType,
      );

      // Notify the auth provider that shop registration is complete
      _authNotifier.onShopRegistered(
        shop: shop,
      );

      state = state.copyWith(
        isLoading: false,
        shop: shop,
        isSuccess: true,
      );

      debugPrint(
        'ShopRegistration: Success — ${shop.shopCode} "${shop.name}"',
      );
    } catch (e) {
      debugPrint('ShopRegistration: Failed — $e');

      String errorMessage = 'Failed to register shop. Please try again.';
      if (e.toString().contains('409')) {
        errorMessage = 'You already have a registered shop.';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Please check your input and try again.';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
