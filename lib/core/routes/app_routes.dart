import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/widgets/main_scaffold.dart';
import 'package:runn_front/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:runn_front/features/login/register/presentation/pages/login_page.dart';
import 'package:runn_front/features/login/register/presentation/pages/register_page.dart';
import 'package:runn_front/features/home/presentation/pages/home_page.dart';
import 'package:runn_front/features/community/presentation/pages/community_page.dart';
import 'package:runn_front/features/territory/presentation/pages/territory_page.dart';
import 'package:runn_front/features/challenges/presentation/pages/challenges_page.dart';
import 'package:runn_front/features/profile/presentation/pages/profile_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized route names and paths for all page files.
abstract final class AppRoutes {
  // Auth / onboarding pages
  static const onboardingPath = '/onboarding';
  static const onboardingName = 'onboarding';
  static const loginPath = '/login';
  static const loginName = 'login';
  static const registerPath = '/register';
  static const registerName = 'register';

  // Main shell pages
  static const homePath = '/home';
  static const homeName = 'home';
  static const communityPath = '/community';
  static const communityName = 'community';
  static const territoriesPath = '/territories';
  static const territoriesName = 'territories';
  static const challengesPath = '/challenges';
  static const challengesName = 'challenges';
  static const profilePath = '/profile';
  static const profileName = 'profile';
}

// Branches order must match MainScaffold nav item order:
// 0 Inicio | 1 Comunidad | 2 Territorios | 3 Retos | 4 Perfil
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.onboardingPath,
  routes: [
    // Onboarding
    GoRoute(
      path: AppRoutes.onboardingPath,
      name: AppRoutes.onboardingName,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Login
    GoRoute(
      path: AppRoutes.loginPath,
      name: AppRoutes.loginName,
      builder: (context, state) => const LoginScreen(),
    ),

    // Register
    GoRoute(
      path: AppRoutes.registerPath,
      name: AppRoutes.registerName,
      builder: (context, state) => const RegisterScreen(),
    ),

    // Shell — main navigation with bottom bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 0 — Inicio
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.homePath,
              name: AppRoutes.homeName,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),

        // 1 — Comunidad
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.communityPath,
              name: AppRoutes.communityName,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: CommunityScreen()),
            ),
          ],
        ),

        // 2 — Territorios
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.territoriesPath,
              name: AppRoutes.territoriesName,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TerritoriesScreen()),
            ),
          ],
        ),

        // 3 — Retos
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.challengesPath,
              name: AppRoutes.challengesName,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ChallengesPage()),
            ),
          ],
        ),

        // 4 — Perfil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profilePath,
              name: AppRoutes.profileName,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);
