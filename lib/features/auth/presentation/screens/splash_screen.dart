import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_constants.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/auth/domain/auth_state.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';

/// Splash screen displayed on app launch.
///
/// Checks for an existing valid session and navigates accordingly:
/// - Valid token + shop → Dashboard
/// - Valid token + no shop → Shop Registration
/// - No token → Login
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

    // Start auth check after animation begins
    Future.delayed(const Duration(milliseconds: 500), () {
      debugPrint('Splash started');
      ref.read(authProvider.notifier).checkAuthStatus();
    });

    // 5-second maximum splash timeout
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final status = ref.read(authProvider).status;
        if (status == AuthStatus.initial || status == AuthStatus.loading) {
          debugPrint('Splash timeout exception: Exceeded 5 seconds. Navigating to Login.');
          context.go('/login');
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
    // Listen for auth state changes to navigate
    ref.listen<AuthState>(authProvider, (previous, next) {
      debugPrint('Router navigation start');
      try {
        if (next.status == AuthStatus.unauthenticated) {
          context.go('/login');
        } else if (next.status == AuthStatus.authenticated) {
          context.go('/dashboard');
        } else if (next.status == AuthStatus.onboardingRequired) {
          context.go('/register-shop');
        }
        debugPrint('Router navigation success');
      } catch (e) {
        debugPrint('Router navigation exception: $e');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
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
                  // App Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Name
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    AppConstants.appTagline,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Loading indicator
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
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
