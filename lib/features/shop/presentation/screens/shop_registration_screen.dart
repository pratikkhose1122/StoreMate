import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/shop/presentation/providers/shop_provider.dart';
import 'package:storemate/shared/widgets/custom_button.dart';

/// Shop registration screen displayed after first login.
///
/// Collects shop details and registers the shop via the backend API.
/// On success, navigates to the dashboard.
class ShopRegistrationScreen extends ConsumerStatefulWidget {
  const ShopRegistrationScreen({super.key});

  @override
  ConsumerState<ShopRegistrationScreen> createState() =>
      _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState
    extends ConsumerState<ShopRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedBusinessType = 'general';

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(shopRegistrationProvider.notifier).registerShop(
          name: _shopNameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          mobileNumber: _mobileController.text.trim().isNotEmpty
              ? _mobileController.text.trim()
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          businessType: _selectedBusinessType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(shopRegistrationProvider);

    // Listen for success → navigate to dashboard
    ref.listen<ShopRegistrationState>(shopRegistrationProvider,
        (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        context.go('/dashboard');
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(shopRegistrationProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Your Shop'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Almost there!',
                              style: AppTextStyles.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Register your shop to start managing inventory',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Shop Name
                _buildLabel('Shop Name *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _shopNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your shop name',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Shop name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Shop name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Owner Name
                _buildLabel('Owner Name *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ownerNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter owner\'s full name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Owner name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Owner name must be at least 2 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Business Type
                _buildLabel('Business Type *'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedBusinessType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: AppConstants.businessTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        AppConstants.businessTypeLabels[type] ?? type,
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedBusinessType = value);
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Mobile Number (optional)
                _buildLabel('Shop Mobile Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Optional — shop contact number',
                    counterText: '',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v != null &&
                        v.isNotEmpty &&
                        !RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email (optional)
                _buildLabel('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Optional — for receipts & invoices',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v != null &&
                        v.isNotEmpty &&
                        !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Address (optional)
                _buildLabel('Shop Address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Optional — shop address',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.location_on_outlined),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v != null && v.length > 500) {
                      return 'Address must not exceed 500 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 36),

                // Submit Button
                CustomButton(
                  text: 'Create My Shop',
                  onPressed: _onSubmit,
                  isLoading: registrationState.isLoading,
                  icon: Icons.rocket_launch_rounded,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.labelLarge);
  }
}
