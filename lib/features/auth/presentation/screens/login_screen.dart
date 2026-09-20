import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/auth/domain/auth_state.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/shared/widgets/custom_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _phoneController.text.trim();
    ref.read(authProvider.notifier).sendOtp(phoneNumber);
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length != 10) {
      return 'Mobile number must be 10 digits';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Indian mobile number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isOtpSent && !(previous?.isOtpSent ?? false)) {
        context.push('/otp', extra: _phoneController.text.trim());
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: context.colors.danger,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Welcome Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 36,
                  color: context.colors.primaryForeground,
                ),
              ),
              const SizedBox(height: 24),

              Text('Welcome to', style: AppTextStyles.bodyLg.copyWith(
                color: context.colors.textSecondary,
              )),
              const SizedBox(height: 4),
              Text(AppConstants.appName, style: AppTextStyles.h1.copyWith(color: context.colors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Enter your mobile number to get started.\nWe\'ll send you a verification code.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 48),

              // Phone Input Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobile Number', style: AppTextStyles.labelLg.copyWith(color: context.colors.textPrimary)),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: _validatePhone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: AppTextStyles.bodyLg.copyWith(
                        color: context.colors.textPrimary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: '9876543210',
                        hintStyle: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.5)),
                        counterText: '',
                        filled: true,
                        fillColor: context.colors.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.colors.border)),
                        prefixIcon: Container(
                          width: 72,
                          alignment: Alignment.center,
                          child: Text(
                            '${AppConstants.countryCode}  ',
                            style: AppTextStyles.bodyLg.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 72,
                          minHeight: 0,
                        ),
                      ),
                      onFieldSubmitted: (_) => _onSendOtp(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Send OTP',
                onPressed: _onSendOtp,
                isLoading: authState.isLoading,
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'By continuing, you agree to our\nTerms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.copyWith(height: 1.6, color: context.colors.textSecondary),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
