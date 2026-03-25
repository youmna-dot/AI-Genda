// lib/core/routes/app_router.dart

import 'package:go_router/go_router.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/onboarding/views/onboarding_screen.dart';
import '../../features/auth/views/auth_screen.dart';
import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/auth/views/confirm_email_screen.dart';
import '../../features/auth/views/reset_password_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/profile/views/edit_profile_screen.dart';
import '../../features/profile/views/change_password_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ══════════════════════════════════════
    // SPLASH
    // ══════════════════════════════════════
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ══════════════════════════════════════
    // ONBOARDING
    // ══════════════════════════════════════
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),

    // ══════════════════════════════════════
    // AUTH
    // ══════════════════════════════════════
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ── Confirm Email ──
    // الـ path ده للـ Flutter navigation الداخلي
    // الـ Deep Link من الباك بيجي على /Auth/confirm-email
    // وبيتحول في main.dart لـ /confirm-email
    GoRoute(
      path: '/confirm-email',
      name: 'confirm-email',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return ConfirmEmailScreen(
          userId: extra['userId'] ?? '',
          email:  extra['email']  ?? '',
        );
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ResetPasswordScreen(email: email);
      },
    ),

    // ══════════════════════════════════════
    // HOME
    // ══════════════════════════════════════
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // ══════════════════════════════════════
    // PROFILE
    // ══════════════════════════════════════
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
  ],
);