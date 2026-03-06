import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/widgets/main_scaffold.dart';
import 'package:runn_front/features/notifications/presentation/pages/notifications_page.dart';
import 'package:runn_front/features/creation_runner_profile/presentation/pages/profile_setup_page.dart';
import 'package:runn_front/features/creation_runner_profile/presentation/pages/physical_metrics_page.dart';
import 'package:runn_front/features/creation_runner_profile/presentation/pages/runner_profile_page.dart';
import 'package:runn_front/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:runn_front/features/login/register/presentation/pages/login_page.dart';
import 'package:runn_front/features/login/register/presentation/pages/register_page.dart';
import 'package:runn_front/features/home/presentation/pages/home_page.dart';
import 'package:runn_front/features/community/presentation/pages/community_page.dart';
import 'package:runn_front/features/community/presentation/pages/groups_page.dart';
import 'package:runn_front/features/community/presentation/pages/create_group_page.dart';
import 'package:runn_front/features/territory/presentation/pages/territory_page.dart';
import 'package:runn_front/features/challenges/presentation/pages/challenges_page.dart';
import 'package:runn_front/features/profile/presentation/pages/profile_page.dart';
import 'package:runn_front/features/start_career/presentation/pages/start_career_page.dart';
import 'package:runn_front/features/run_results/presentation/pages/run_results_page.dart';
import 'package:runn_front/features/community/presentation/pages/rival_profile_page.dart';
import 'package:runn_front/features/community/presentation/pages/event_detail_page.dart';
import 'package:runn_front/features/profile/presentation/pages/my_statistics_page.dart';
import 'package:runn_front/features/profile/presentation/pages/my_badges_page.dart';
import 'package:runn_front/features/profile/presentation/pages/settings_page.dart';
import 'package:runn_front/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:runn_front/features/profile/presentation/pages/wearables_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Branches order matches MainScaffold nav item order:
// 0 Inicio | 1 Comunidad | 2 Territorios | 3 Retos | 4 Perfil
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    // Onboarding
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Login
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Register
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Sub-routes (Global) - Pushed over Bottom Bar


    // Start Career (outside shell — full screen)
    GoRoute(
      path: '/start_career',
      name: 'start_career',
      builder: (context, state) => const StartCareerScreen(),
    ),

    // Notifications (outside shell — full screen)
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // Runner profile creation flow (Step 1)
    GoRoute(
      path: '/profile_setup',
      name: 'profile_setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),

    // Runner profile creation flow (Step 2)
    GoRoute(
      path: '/physical_metrics',
      name: 'physical_metrics',
      builder: (context, state) => const PhysicalMetricsScreen(),
    ),

    // Runner profile creation flow (Step 3)
    GoRoute(
      path: '/runner_profile',
      name: 'runner_profile',
      builder: (context, state) => const RunnerProfileScreen(),
    ),

    // Run Results (outside shell — full screen)
    GoRoute(
      path: '/run_results',
      name: 'run_results',
      builder: (context, state) => const RunResultsScreen(),
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
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),

        // 1 — Comunidad
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              name: 'community',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: CommunityScreen()),
              routes: [
                GoRoute(
                  path: 'groups',
                  name: 'groups',
                  builder: (context, state) => const GroupsPage(),
                  routes: [
                    GoRoute(
                      path: 'create',
                      name: 'create_group',
                      builder: (context, state) => const CreateGroupPage(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'rival-profile/:userId',
                  name: 'rival_profile',
                  builder: (context, state) {
                    final userId = state.pathParameters['userId']!;
                    return RivalProfilePage(userId: userId);
                  },
                ),
                GoRoute(
                  path: 'event/:eventId',
                  name: 'event_detail',
                  builder: (context, state) {
                    final eventId = state.pathParameters['eventId']!;
                    return EventDetailPage(eventId: eventId);
                  },
                ),
              ],
            ),
          ],
        ),

        // 2 — Territorios
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

        // 3 — Retos
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

        // 4 — Perfil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: ProfileScreen()),
              routes: [
                GoRoute(
                  path: 'stats',
                  name: 'profile_stats',
                  builder: (context, state) => const MyStatisticsPage(),
                ),
                GoRoute(
                  path: 'badges',
                  name: 'profile_badges',
                  builder: (context, state) => const MyBadgesPage(),
                ),
                GoRoute(
                  path: 'settings',
                  name: 'profile_settings',
                  builder: (context, state) => const SettingsPage(),
                ),
                GoRoute(
                  path: 'edit',
                  name: 'profile_edit',
                  builder: (context, state) => const EditProfilePage(),
                ),
                GoRoute(
                  path: 'wearables',
                  name: 'profile_wearables',
                  builder: (context, state) => const WearablesPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
