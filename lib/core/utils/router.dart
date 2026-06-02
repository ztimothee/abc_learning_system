import 'package:abc_learning_system/features/accounts_ledgers/screens/faculty_account_ledgers_screen.dart';
import 'package:abc_learning_system/features/accounts_ledgers/screens/student_account_ledgers_screen.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/screens/login_screen.dart';
import 'package:abc_learning_system/features/auth/screens/theme_settings_screen.dart';
import 'package:abc_learning_system/features/auth/screens/sign_up_screen.dart';
import 'package:abc_learning_system/features/enrollments/screens/staff_enrollment_screen.dart';
import 'package:abc_learning_system/features/enrollments/screens/student_enrollment_screen.dart';
import 'package:abc_learning_system/features/enrollments/screens/tutor_enrollment_screen.dart';
import 'package:abc_learning_system/features/profile/screens/profile_screen.dart';
import 'package:abc_learning_system/features/student_records/screens/student_records_screen.dart';
import 'package:abc_learning_system/features/student_records/screens/tutor_student_records_screen.dart';
import 'package:abc_learning_system/shared/staffs/screens/staff_dashboard_screen.dart';
import 'package:abc_learning_system/shared/students/screens/student_dashboard_screen.dart';
import 'package:abc_learning_system/shared/tutors/screens/tutor_dashboard_screen.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final isLoggingOut = ref.watch(isLoggingOutProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final currentRoute = state.matchedLocation;
      final isAuthScreen =
          currentRoute == '/login' || currentRoute == '/signup';
      final isThemeSettings = currentRoute == '/settings';

      if (profileAsync.isLoading) {
        return '/loading';
      }

      if (profileAsync.hasError) {
        return '/login';
      }

      final profile = profileAsync.value;

      if (profile == null) {
        return (isAuthScreen || isThemeSettings) ? null : '/login';
      }

      if (isAuthScreen) {
        switch (profile.role) {
          case 'student':
            return '/student/profile';
          case 'tutor':
            return '/tutor/profile';
          case 'staff':
            return '/staff/profile';
          default:
            return '/login';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => AppLoadingScreen(
          message: isLoggingOut ? 'Logging out...' : 'Loading profile...',
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final errorMessage = profileAsync.hasError
              ? 'Error loading profile: ${profileAsync.error}'
              : null;
          return LoginScreen(errorMessage: errorMessage);
        },
      ),
      GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),

      // -- STUDENT DASHBOARD ROUTE --
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            StudentDashboardScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student/profile',
                builder: (context, state) => ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student/enrollments',
                builder: (context, state) => StudentEnrollmentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student/records',
                builder: (context, state) => StudentRecordsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student/accounts',
                builder: (context, state) => StudentAccountLedgersScreen(),
              ),
            ],
          ),
        ],
      ),

      // -- TUTOR DASHBOARD ROUTE --
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            TutorDashboardScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tutor/profile',
                builder: (context, state) => ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tutor/enrollments',
                builder: (context, state) => TutorEnrollmentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tutor/records',
                builder: (context, state) => TutorStudentRecordsScreen(),
              ),
            ],
          ),
        ],
      ),

      // -- STAFF DASHBOARD ROUTE --
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            StaffDashboardScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/profile',
                builder: (context, state) => ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/enrollments',
                builder: (context, state) => StaffEnrollmentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff/accounts',
                builder: (context, state) => FacultyAccountLedgersScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
