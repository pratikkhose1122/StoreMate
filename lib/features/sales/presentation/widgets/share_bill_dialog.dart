import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';

class ShareBillDialog extends StatefulWidget {
  final String? initialPhoneNumber;

  const ShareBillDialog({
    super.key,
    this.initialPhoneNumber,
  });

  @override
  State<ShareBillDialog> createState() => _ShareBillDialogState();
}

class _ShareBillDialogState extends State<ShareBillDialog> {
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    String initialText = '';
    if (widget.initialPhoneNumber != null && widget.initialPhoneNumber!.isNotEmpty) {
      initialText = _stripCountryCode(widget.initialPhoneNumber!);
    }
    _phoneController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _stripCountryCode(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (normalized.startsWith('91') && normalized.length == 12) {
      return normalized.substring(2);
    }
    // Already 10 digits
    if (normalized.length == 10) {
      return normalized;
    }
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: context.colors.background,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // WhatsApp icon + title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Color(0xFF25D366), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Send Bill via WhatsApp',
                    style: AppTextStyles.titleMd.copyWith(color: context.colors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the customer\'s WhatsApp number.\nThe bill PDF will be attached automatically.',
                style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'WhatsApp Number',
                style: AppTextStyles.labelMd.copyWith(color: context.colors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  prefixText: '+91  ',
                  prefixStyle: AppTextStyles.bodyMd.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: '9876543210',
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: context.colors.textSecondary.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: context.colors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF25D366), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.danger),
                  ),
                ),
                style: AppTextStyles.bodyLg.copyWith(
                  color: context.colors.textPrimary,
                  letterSpacing: 1.2,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a number';
                  }
                  if (value.trim().length != 10) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final digits = _phoneController.text.trim();
                          // Return clean 10-digit number — BillSharingService handles +91 prefix
                          Navigator.of(context).pop(digits);
                        }
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Send Bill'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366), // WhatsApp green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
