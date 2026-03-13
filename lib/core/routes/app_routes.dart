import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runn_front/core/widgets/main_scaffold.dart';
import 'package:runn_front/features/notifications/presentation/pages/notifications_page.dart';
import 'package:runn_front/features/creation_runner_profile/presentation/pages/profile_setup_page.dart';
import 'package:runn_front/features/creation_runner_profile/presentation/pages/physical_metrics_page.dart';
import 'package:runn_front/features/creation_runner_profile/presentation/pages/runner_profile_page.dart';
import 'package:runn_front/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:runn_front/core/widgets/splash_page.dart';
import 'package:runn_front/features/login/register/presentation/pages/login_page.dart';
import 'package:runn_front/features/login/register/presentation/pages/register_page.dart';
import 'package:runn_front/features/home/presentation/pages/home_page.dart';
import 'package:runn_front/features/community/presentation/pages/community_page.dart';
import 'package:runn_front/features/community/presentation/pages/runners_page.dart';
import 'package:runn_front/features/community/presentation/pages/groups_page.dart';
import 'package:runn_front/features/community/presentation/pages/group_detail_page.dart';
import 'package:runn_front/features/community/presentation/pages/create_group_page.dart';
import 'package:runn_front/features/territory/presentation/pages/territory_page.dart';
import 'package:runn_front/features/territory/presentation/pages/territory_detail_page.dart';
import 'package:runn_front/features/territory/presentation/pages/territory_ranking_page.dart';
import 'package:runn_front/features/territory/presentation/pages/territory_runner_profile_page.dart';
import 'package:runn_front/features/challenges/presentation/pages/challenges_page.dart';
import 'package:runn_front/features/challenges/presentation/pages/weekly_challenge_detail_page.dart';
import 'package:runn_front/features/challenges/presentation/pages/past_weekly_challenges_page.dart';
import 'package:runn_front/features/challenges/presentation/pages/challenge_item_detail_page.dart';
import 'package:runn_front/features/challenges/presentation/pages/community_race_detail_page.dart';
import 'package:runn_front/features/profile/presentation/pages/profile_page.dart';
import 'package:runn_front/features/start_career/presentation/pages/start_career_page.dart';
import 'package:runn_front/features/run_results/presentation/pages/run_results_page.dart';
import 'package:runn_front/features/community/presentation/pages/rival_profile_page.dart';
import 'package:runn_front/features/community/presentation/pages/multimedia_page.dart';
import 'package:runn_front/features/community/presentation/pages/event_detail_page.dart';
import 'package:runn_front/features/community/presentation/pages/event_participants_page.dart';
import 'package:runn_front/features/community/presentation/pages/participant_profile_page.dart';
import 'package:runn_front/features/profile/presentation/pages/my_statistics_page.dart';
import 'package:runn_front/features/profile/presentation/pages/my_badges_page.dart';
import 'package:runn_front/features/profile/presentation/pages/settings_page.dart';
import 'package:runn_front/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:runn_front/features/community/presentation/pages/rival_details_page.dart';
import 'package:runn_front/features/profile/presentation/pages/wearables_page.dart';
import 'package:runn_front/features/profile/presentation/pages/profile_multimedia_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Branches order matches MainScaffold nav item order:
// 0 Inicio | 1 Comunidad | 2 Territorios | 3 Retos | 4 Perfil
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) {
        // Por defecto redirige a onboarding, pero acepta custom nextRoute
        final nextRoute = state.extra as String? ?? '/onboarding';
        return SplashPage(nextRoute: nextRoute);
      },
    ),
    
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
                  path: 'runners',
                  name: 'community_runners',
                  builder: (context, state) => const RunnersPage(),
                ),
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
                    GoRoute(
                      path: 'detail',
                      name: 'group_detail',
                      builder: (context, state) {
                        final groupData = state.extra as Map<String, dynamic>?;
                        return GroupDetailPage(groupData: groupData);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'rival-details/:userId',
                  name: 'rival_details',
                  builder: (context, state) {
                    final userId = state.pathParameters['userId']!;
                    final extraData = state.extra as Map<String, dynamic>?;
                    return RivalDetailsPage(
                      userId: userId,
                      rivalData: extraData,
                    );
                  },
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
                  path: 'multimedia/:userId',
                  name: 'rival_multimedia',
                  builder: (context, state) {
                    final userId = state.pathParameters['userId']!;
                    final extra = state.extra;
                    return MultimediaPage(userId: userId, extra: extra);
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
                GoRoute(
                  path: 'event/:eventId/participants',
                  name: 'event_participants',
                  builder: (context, state) {
                    final eventId = state.pathParameters['eventId']!;
                    return EventParticipantsPage(eventId: eventId);
                  },
                ),
                GoRoute(
                  path: 'event/:eventId/participant/:userId',
                  name: 'participant_profile',
                  builder: (context, state) {
                    final eventId = state.pathParameters['eventId']!;
                    final userId = state.pathParameters['userId']!;
                    final extraData = state.extra as Map<String, dynamic>?;
                    return ParticipantProfilePage(
                      eventId: eventId,
                      userId: userId,
                      participantData: extraData,
                    );
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
                  NoTransitionPage(child: TerritoriesScreen()),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  name: 'territory_detail',
                  builder: (context, state) {
                    final idStr = state.pathParameters['id']!;
                    final id = int.tryParse(idStr) ?? 1;
                    return TerritoryDetailView(
                      territoryId: id,
                      onBack: () => context.pop(),
                    );
                  },
                ),
                GoRoute(
                  path: 'ranking',
                  name: 'territory_ranking',
                  builder: (context, state) => const TerritoryRankingPage(),
                ),
                GoRoute(
                  path: 'runner/:runnerId',
                  name: 'territory_runner_profile',
                  builder: (context, state) {
                    final runnerId = state.pathParameters['runnerId']!;
                    return TerritoryRunnerProfilePage(runnerId: runnerId);
                  },
                ),
              ],
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
              routes: [
                GoRoute(
                  path: 'weekly',
                  name: 'challenge_weekly',
                  builder: (context, state) =>
                      const WeeklyChallengeDetailPage(),
                ),
                GoRoute(
                  path: 'past',
                  name: 'challenge_past',
                  builder: (context, state) =>
                      const PastWeeklyChallengesPage(),
                ),
                GoRoute(
                  path: 'challenge/:challengeId',
                  name: 'challenge_item',
                  builder: (context, state) {
                    final id = state.pathParameters['challengeId']!;
                    return ChallengeItemDetailPage(challengeId: id);
                  },
                ),
                GoRoute(
                  path: 'race/:raceId',
                  name: 'challenge_race',
                  builder: (context, state) {
                    final id = state.pathParameters['raceId']!;
                    return CommunityRaceDetailPage(raceId: id);
                  },
                ),
              ],
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
                  builder: (context, state) => SettingsPage(),
                ),
                GoRoute(
                  path: 'edit',
                  name: 'profile_edit',
                  builder: (context, state) => const EditProfilePage(),
                ),
                GoRoute(
                  path: 'wearables',
                  name: 'profile_wearables',
                  builder: (context, state) => WearablesPage(),
                ),
                GoRoute(
                  path: 'multimedia',
                  name: 'profile_multimedia',
                  builder: (context, state) => const ProfileMultimediaPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
