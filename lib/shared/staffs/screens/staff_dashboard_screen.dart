import 'package:abc_learning_system/core/themes/ui.dart';
import 'package:abc_learning_system/shared/widgets/custom_brand_item.dart';
import 'package:abc_learning_system/shared/widgets/custom_navigation_rail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffDashboardScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StaffDashboardScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              CustomBrandItem(
                title: 'ABC Learning System',
                logo: AppAssets.logo(width: 40),
              ),
              const Divider(),
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
                      icon: Icons.account_circle_outlined,
                      selectedIcon: Icons.account_circle,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () {
                        context.go('/logout');
                      },
                      tooltip: 'Logout',
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell)
        ],
      )
    );
  }
}