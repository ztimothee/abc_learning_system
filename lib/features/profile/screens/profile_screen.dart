import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/core/themes/status_map.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:abc_learning_system/shared/staffs/controllers/staff_repository.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:abc_learning_system/shared/tutors/controllers/tutor_repository.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final fullName = buildFullNameSurnameFirst(
      profile.firstName,
      profile.middleName,
      profile.lastName,
    );
    final initials = buildInitials(profile);
    const schoolYear = 'SY 2026-2027';
    final enrollmentStatus = profile.role.currentRoleInt == 0
        ? 'Enrolled'
        : profile.role.currentRoleInt == 1
        ? 'Teaching'
        : profile.role.currentRoleInt == 2
        ? 'Admin'
        : 'N/A';
    final currentRole = profile.role.currentRoleInt;
    final userId = profile.userId;
    final idLabel = currentRole == 0
        ? 'Student ID'
        : currentRole == 1
        ? 'Teacher ID'
        : currentRole == 2
        ? 'Admin ID'
        : 'User ID';

    AsyncValue<String?> displayIdAsync = const AsyncValue.data(null);
    if (userId != null && userId.isNotEmpty) {
      if (currentRole == 0) {
        displayIdAsync = ref
            .watch(studentProfileByUserIdProvider(userId))
            .whenData((student) => student.displayId);
      } else if (currentRole == 1) {
        displayIdAsync = ref
            .watch(tutorProfileByUserIdProvider(userId))
            .whenData((tutor) => tutor.displayId);
      } else if (currentRole == 2) {
        displayIdAsync = ref
            .watch(staffProfileByUserIdProvider(userId))
            .whenData((staff) => staff?.displayId);
      }
    }

    final idValue = displayIdAsync.when(
      data: (displayId) =>
          (displayId != null && displayId.isNotEmpty) ? displayId : 'N/A',
      loading: () => 'Loading...',
      error: (_, _) => 'N/A',
    );

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
                InfoRow(label: idLabel, value: idValue),
                InfoRow(label: 'Gender', value: profile.gender),
                InfoRow(
                  label: 'Date of Birth',
                  value: formatDate(profile.dateOfBirth),
                ),
                InfoRow(
                  label: 'Civil Status',
                  value: profile.civilStatus.civilStatusString,
                ),
                InfoRow(label: 'Contact', value: profile.contactNumber),
                InfoRow(label: 'Address', value: profile.address),
                if (profile.position != null)
                  InfoRow(label: 'Position', value: profile.position!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (currentRole == 2) ...[
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                maximumSize: const Size(250, 64),
              ),
              onPressed: () {
                context.push('/staff/profile/signup');
              },
              child: const Text('Create Account'),
            ),
          ),
        ],
      ],
    );
  }
}
