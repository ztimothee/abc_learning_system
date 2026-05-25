import 'package:abc_learning_system/core/themes/status_map.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error loading profile: $error')),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final Profile profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = _buildFullName(profile);
    final initials = _buildInitials(profile);
    const schoolYear = 'SY 2026-2027';
    const enrollmentStatus = 'Enrolled';

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
              children: [
                _InfoRow(label: 'Student ID', value: profile.userId ?? 'N/A'),
                _InfoRow(label: 'Gender', value: profile.gender),
                _InfoRow(
                  label: 'Date of Birth',
                  value: _formatDate(profile.dateOfBirth),
                ),
                _InfoRow(
                  label: 'Civil Status',
                  value: profile.civilStatus.civilStatus,
                ),
                _InfoRow(label: 'Contact', value: profile.contactNumber),
                _InfoRow(label: 'Address', value: profile.address),
                if (profile.position != null)
                  _InfoRow(label: 'Position', value: profile.position!),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _buildFullName(Profile profile) {
    final parts = [
      profile.firstName,
      if (profile.middleName != null && profile.middleName!.trim().isNotEmpty)
        profile.middleName!.trim(),
      profile.lastName,
    ];

    return parts.join(' ');
  }

  String _buildInitials(Profile profile) {
    final first = profile.firstName.trim();
    final last = profile.lastName.trim();
    final firstChar = first.isNotEmpty ? first[0] : '';
    final lastChar = last.isNotEmpty ? last[0] : '';
    final initials = (firstChar + lastChar).toUpperCase();

    return initials.isEmpty ? '?' : initials;
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
