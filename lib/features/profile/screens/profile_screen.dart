import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/core/themes/status_map.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found.'));
          }

          return _ProfileBody(profile: profile);
        },
        loading: () => const AppLoadingScreen(),
        error: (error, _) =>
            Center(child: Text('Error loading profile: $error')),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final Profile profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fullName = buildFullName(profile);
    final initials = buildInitials(profile);
    const schoolYear = 'SY 2026-2027';
    final enrollmentStatus = profile.role.currentRoleValue == 0
        ? 'Enrolled'
        : profile.role.currentRoleValue == 1
        ? 'Teaching'
        : profile.role.currentRoleValue == 2
        ? 'Admin'
        : 'N/A';
    final currentRole = profile.role.currentRoleValue;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                initials,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.role.toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schoolYear,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enrollmentStatus,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentRole == 0)
                  InfoRow(label: 'Student ID', value: profile.userId ?? 'N/A')
                else if (currentRole == 1)
                  InfoRow(label: 'Teacher ID', value: profile.userId ?? 'N/A')
                else if (currentRole == 2)
                  InfoRow(label: 'Admin ID', value: profile.userId ?? 'N/A')
                else
                  InfoRow(label: 'User ID', value: profile.userId ?? 'N/A'),
                InfoRow(label: 'Gender', value: profile.gender),
                InfoRow(
                  label: 'Date of Birth',
                  value: formatDate(profile.dateOfBirth),
                ),
                InfoRow(
                  label: 'Civil Status',
                  value: profile.civilStatus.civilStatus,
                ),
                InfoRow(label: 'Contact', value: profile.contactNumber),
                InfoRow(label: 'Address', value: profile.address),
                if (profile.position != null)
                  InfoRow(label: 'Position', value: profile.position!),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
