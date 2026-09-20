import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/auth/domain/auth_state.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  
  String _diagnosticStatus = "Initializing App...";

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _diagnosticStatus = "Checking Session...";
        });
      }
      ref.read(authProvider.notifier).checkAuthStatus();
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        final status = ref.read(authProvider).status;
        if (status == AuthStatus.initial || status == AuthStatus.loading) {
          setState(() {
            _diagnosticStatus = "Timeout. Navigating to Login...";
          });
          debugPrint('Navigation Start: ${DateTime.now().toIso8601String()}');
          context.go('/login');
          debugPrint('Navigation Complete: ${DateTime.now().toIso8601String()}');
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      debugPrint('Navigation Start: ${DateTime.now().toIso8601String()}');
      try {
        if (next.status == AuthStatus.unauthenticated) {
          if (mounted) setState(() => _diagnosticStatus = "Navigating to Login...");
          context.go('/login');
        } else if (next.status == AuthStatus.authenticated) {
          if (mounted) setState(() => _diagnosticStatus = "Navigating to Dashboard...");
          context.go('/dashboard');
        } else if (next.status == AuthStatus.onboardingRequired) {
          if (mounted) setState(() => _diagnosticStatus = "Navigating to Shop Setup...");
          context.go('/register-shop');
        }
        debugPrint('Navigation Complete: ${DateTime.now().toIso8601String()}');
      } catch (e) {
        debugPrint('Router navigation exception: $e');
      }
    });

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Container(
        color: context.colors.primary,
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: context.colors.background.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: context.colors.background.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 56,
                      color: context.colors.primaryForeground,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.h1.copyWith(
                      color: context.colors.primaryForeground,
                      fontSize: 36,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: context.colors.primaryForeground.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.primaryForeground.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    _diagnosticStatus,
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.colors.primaryForeground.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
