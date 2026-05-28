import 'package:abc_learning_system/core/themes/ui.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/shared/widgets/custom_brand_item.dart';
import 'package:abc_learning_system/shared/widgets/custom_navigation_actions_item.dart';
import 'package:abc_learning_system/shared/widgets/custom_navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TutorDashboardScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const TutorDashboardScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomBrandItem(
                  title: 'ABC Academy',
                  logo: AppAssets.logo(width: 40),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: CustomNavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: (index) {
                      navigationShell.goBranch(index);
                    },
                    destinations: [
                      CustomNavigationRailDestination(
                        label: 'Profile',
                        icon: Icons.person_outline,
                        selectedIcon: Icons.person,
                      ),
                      CustomNavigationRailDestination(
                        label: 'Enrollments',
                        icon: Icons.book_outlined,
                        selectedIcon: Icons.book,
                      ),
                      CustomNavigationRailDestination(
                        label: 'Student Records',
                        icon: Icons.school_outlined,
                        selectedIcon: Icons.school,
                      ),
                      CustomNavigationRailDestination(
                        label: 'Accounts',
                        icon: Icons.account_balance_outlined,
                        selectedIcon: Icons.account_balance,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      CustomNavigationActionsItem(
                        label: 'Settings',
                        icon: Icons.settings,
                        onPressed: () {
                          context.push(
                            '/settings',
                          ); // Uncomment and implement settings route when ready
                        },
                      ),
                      const SizedBox(height: 8),
                      CustomNavigationActionsItem(
                        label: 'Logout',
                        icon: Icons.logout,
                        onPressed: () {
                          authService.logout();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
