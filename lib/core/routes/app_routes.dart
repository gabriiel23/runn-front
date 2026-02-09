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

// Global keys for navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// GoRouter configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    // Onboarding route
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Login route
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Register route
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Shell route for main navigation with bottom bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),

        // Community branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              name: 'community',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: CommunityScreen()),
            ),
          ],
        ),

        // Territories branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/territories',
              name: 'territories',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TerritoriesScreen()),
            ),
          ],
        ),

        // Challenges branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/challenges',
              name: 'challenges',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ChallengesPage()),
            ),
          ],
        ),

        // Profile branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);
