import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/shop/presentation/providers/shop_provider.dart';
import 'package:storemate/shared/widgets/custom_button.dart';

class ShopRegistrationScreen extends ConsumerStatefulWidget {
  const ShopRegistrationScreen({super.key});

  @override
  ConsumerState<ShopRegistrationScreen> createState() =>
      _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState
    extends ConsumerState<ShopRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();

  String? _selectedBusinessType;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _shopNameController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedBusinessType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a business category'),
          backgroundColor: context.colors.danger,
        ),
      );
      return;
    }

    ref.read(shopRegistrationProvider.notifier).registerShop(
          name: _shopNameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          gstNumber: _gstController.text.trim().isNotEmpty
              ? _gstController.text.trim()
              : null,
          businessType: _selectedBusinessType!,
        );
  }

  IconData _getCategoryIcon(String type) {
    switch (type) {
      case 'kirana': return Icons.shopping_basket_outlined;
      case 'medical': return Icons.local_pharmacy_outlined;
      case 'clothing': return Icons.checkroom_outlined;
      case 'electronics': return Icons.devices_outlined;
      case 'restaurant': return Icons.restaurant_outlined;
      case 'stationery': return Icons.edit_outlined;
      case 'hardware': return Icons.handyman_outlined;
      case 'general': return Icons.storefront_outlined;
      case 'other': return Icons.category_outlined;
      default: return Icons.store_outlined;
    }
  }

  InputDecoration _inputDecoration(BuildContext context, String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5)),
      fillColor: context.colors.card,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(shopRegistrationProvider);

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
            backgroundColor: context.colors.danger,
          ),
        );
        ref.read(shopRegistrationProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: context.colors.background,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  title: Text('Shop Setup Wizard', style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary)),
                  background: Container(color: context.colors.background),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    Text('Let\'s get your store online in a few easy steps.', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary)),
                    const SizedBox(height: 32),

                    // Step 1
                    _buildStepHeader(context, 'Step 1', 'Owner Name'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ownerNameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: context.colors.textPrimary),
                      decoration: _inputDecoration(context, 'Enter owner\'s full name', prefixIcon: Icon(Icons.person_outline, color: context.colors.textPrimary)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),

                    // Step 2
                    _buildStepHeader(context, 'Step 2', 'Shop Name'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _shopNameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: context.colors.textPrimary),
                      decoration: _inputDecoration(context, 'Enter your shop name', prefixIcon: Icon(Icons.storefront_outlined, color: context.colors.textPrimary)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),

                    // Step 3
                    _buildStepHeader(context, 'Step 3', 'Business Category'),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: AppConstants.businessTypes.length,
                      itemBuilder: (context, index) {
                        final type = AppConstants.businessTypes[index];
                        final isSelected = _selectedBusinessType == type;
                        return InkWell(
                          onTap: () => setState(() => _selectedBusinessType = type),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? context.colors.primary : context.colors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? context.colors.primary : context.colors.border,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: context.colors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ] : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getCategoryIcon(type),
                                  color: isSelected ? context.colors.primaryForeground : context.colors.primary,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppConstants.businessTypeLabels[type] ?? type,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: isSelected ? context.colors.primaryForeground : context.colors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Step 4
                    _buildStepHeader(context, 'Step 4', 'Address'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: context.colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter full shop address',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 48),
                          child: Icon(Icons.location_on_outlined, color: context.colors.textPrimary),
                        ),
                        alignLabelWithHint: true,
                        hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5)),
                        fillColor: context.colors.card,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),

                    // Step 5
                    _buildStepHeader(context, 'Step 5', 'GST Number (Optional)'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _gstController,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(color: context.colors.textPrimary),
                      decoration: _inputDecoration(context, 'e.g. 22AAAAA0000A1Z5', prefixIcon: Icon(Icons.receipt_long_outlined, color: context.colors.textPrimary)),
                    ),
                    const SizedBox(height: 48),

                    // Step 6
                    CustomButton(
                      text: 'Step 6: Create Shop',
                      onPressed: _onSubmit,
                      isLoading: registrationState.isLoading,
                      icon: Icons.rocket_launch_rounded,
                    ),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(BuildContext context, String step, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: AppTextStyles.labelMd.copyWith(
            color: context.colors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: AppTextStyles.titleLg.copyWith(color: context.colors.textPrimary)),
      ],
    );
  }
}
