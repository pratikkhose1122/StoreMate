import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/core/providers/theme_provider.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/features/shop/presentation/providers/shop_provider.dart';
import 'package:storemate/shared/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/widgets/app_list_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _businessTypeController;
  late TextEditingController _gstController;
  late TextEditingController _invoicePrefixController;
  late TextEditingController _upiIdController;
  
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    final shop = authState.shop;
    final user = authState.user;
    
    _shopNameController = TextEditingController(text: shop?.name ?? '');
    _ownerNameController = TextEditingController(text: shop?.ownerName ?? '');
    _mobileController = TextEditingController(text: shop?.mobileNumber ?? user?.mobileNumber ?? '');
    _emailController = TextEditingController(text: shop?.email ?? '');
    _addressController = TextEditingController(text: shop?.address ?? '');
    _businessTypeController = TextEditingController(text: shop?.businessType ?? 'general');
    _gstController = TextEditingController(text: shop?.gstNumber ?? '');
    _invoicePrefixController = TextEditingController(text: shop?.invoicePrefix ?? 'INV');
    _upiIdController = TextEditingController(text: shop?.upiId ?? '');
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _businessTypeController.dispose();
    _gstController.dispose();
    _invoicePrefixController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      _uploadLogo();
    }
  }

  Future<void> _uploadLogo() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(shopRepositoryProvider).uploadLogo(_selectedImage!.path);
      
      await ref.read(authProvider.notifier).checkAuthStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload logo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(shopRepositoryProvider).updateSettings({
        'name': _shopNameController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'mobileNumber': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'businessType': _businessTypeController.text.trim(),
        'gstin': _gstController.text.trim(),
        'invoicePrefix': _invoicePrefixController.text.trim(),
        'upiId': _upiIdController.text.trim(),
      });
      
      await ref.read(authProvider.notifier).checkAuthStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update settings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(authProvider).shop;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Appearance Section
            Text('Appearance', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('System Default', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode!),
                    activeColor: context.colors.primary,
                  ),
                  Divider(color: context.colors.border, height: 1),
                  RadioListTile<ThemeMode>(
                    title: Text('Light Mode', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode!),
                    activeColor: context.colors.primary,
                  ),
                  Divider(color: context.colors.border, height: 1),
                  RadioListTile<ThemeMode>(
                    title: Text('Dark Mode', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode!),
                    activeColor: context.colors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Shop Profile Section
            Text('Shop Profile', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: context.colors.elevatedCard,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (shop?.logoUrl != null ? NetworkImage(shop!.logoUrl!) : null) as ImageProvider?,
                          child: _selectedImage == null && shop?.logoUrl == null 
                              ? Icon(Icons.store, size: 40, color: context.colors.textSecondary) 
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          icon: Icon(Icons.upload, color: context.colors.primary),
                          label: Text('Upload Logo', style: AppTextStyles.labelMd.copyWith(color: context.colors.primary)),
                          onPressed: _pickImage,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Shop Name
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Shop Name',
                      prefixIcon: Icon(Icons.store, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _shopNameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Shop name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Owner Name
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Owner Name',
                      prefixIcon: Icon(Icons.person, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _ownerNameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Owner name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Mobile Number
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Shop Address',
                      prefixIcon: Icon(Icons.location_on, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      hintText: 'Enter your full shop address',
                      hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5)),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _addressController,
                    maxLines: 3,
                    minLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Business Settings header
                  Text('Business Settings', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
                  const SizedBox(height: 12),

                  // Business Type
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Business Type',
                      prefixIcon: Icon(Icons.business, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _businessTypeController,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // GST Number
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'GST Number',
                      hintText: 'e.g., 22AAAAA0000A1Z5',
                      prefixIcon: Icon(Icons.receipt_long, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5)),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _gstController,
                  ),
                  const SizedBox(height: 16),

                  // Invoice Prefix
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Invoice Prefix',
                      hintText: 'e.g., INV, SHOP',
                      prefixIcon: Icon(Icons.tag, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5)),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _invoicePrefixController,
                    maxLength: 10,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 2) return 'Min 2 characters';
                      if (!RegExp(r'^[A-Z]+$').hasMatch(v)) return 'Must be uppercase letters A-Z only';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // UPI ID
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'UPI ID',
                      hintText: 'e.g., yourshop@upi',
                      prefixIcon: Icon(Icons.qr_code, color: context.colors.textSecondary),
                      labelStyle: TextStyle(color: context.colors.textSecondary),
                      hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5)),
                      fillColor: context.colors.card,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                    ),
                    style: TextStyle(color: context.colors.textPrimary),
                    controller: _upiIdController,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Save Settings',
                    isLoading: _isLoading,
                    onPressed: _saveSettings,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            // Hardware Settings
            Text('Hardware', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: AppListTile(
                leading: Icon(Icons.print, color: context.colors.primary),
                title: 'Thermal Printer',
                subtitle: 'Configure Bluetooth receipt printer',
                onTap: () => context.push('/settings/printer'),
              ),
            ),
            const SizedBox(height: 32),
            // Account
            Text('Account', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.danger.withValues(alpha: 0.3)),
              ),
              child: AppListTile(
                leading: Icon(Icons.logout, color: context.colors.danger),
                title: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
