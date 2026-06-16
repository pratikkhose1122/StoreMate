import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/features/shop/presentation/providers/shop_provider.dart';
import 'package:storemate/shared/widgets/custom_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessTypeController;
  late TextEditingController _gstController;
  late TextEditingController _invoicePrefixController;
  
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final shop = ref.read(authProvider).shop;
    _businessTypeController = TextEditingController(text: shop?.businessType ?? 'general');
    _gstController = TextEditingController(text: shop?.gstNumber ?? '');
    _invoicePrefixController = TextEditingController(text: shop?.invoicePrefix ?? 'INV');
  }

  @override
  void dispose() {
    _businessTypeController.dispose();
    _gstController.dispose();
    _invoicePrefixController.dispose();
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
      
      // We don't have a direct refresh for shop profile in authProvider,
      // but getting profile again will fetch the updated shop.
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
        'businessType': _businessTypeController.text,
        'gstNumber': _gstController.text,
        'invoicePrefix': _invoicePrefixController.text,
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

    return Scaffold(
      appBar: AppBar(title: const Text('Shop Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (shop?.logoUrl != null ? NetworkImage(shop!.logoUrl!) : null) as ImageProvider?,
                        child: _selectedImage == null && shop?.logoUrl == null 
                            ? const Icon(Icons.store, size: 40, color: Colors.grey) 
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Logo'),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Business Type'),
                controller: _businessTypeController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'GST Number', hintText: 'e.g., 22AAAAA0000A1Z5'),
                controller: _gstController,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Invoice Prefix', hintText: 'e.g., INV, SHOP'),
                controller: _invoicePrefixController,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 2) return 'Min 2 characters';
                  if (!RegExp(r'^[A-Z]+$').hasMatch(v)) return 'Must be uppercase letters A-Z only';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Settings',
                isLoading: _isLoading,
                onPressed: _saveSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

