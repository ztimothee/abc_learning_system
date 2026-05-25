import 'dart:async';

import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:abc_learning_system/features/enrollments/controllers/enrollment_repository.dart';
import 'package:abc_learning_system/features/enrollments/models/enrollment_items_dto.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/custom_ink_well_list.dart';
import 'package:abc_learning_system/shared/widgets/info_row.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentEnrollmentScreen extends ConsumerWidget {
  const StudentEnrollmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Student Enrollment')),
      body: profile.when(
        loading: () => const AppLoadingScreen(),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (data) {
          if (data == null) {
            return const Center(
              child: Text(
                'No student profile is available for the current user.',
              ),
            );
          }

          return StudentEnrollmentScreenBody(profile: data);
        },
      ),
    );
  }
}

class StudentEnrollmentScreenBody extends ConsumerWidget {
  final Profile profile;
  const StudentEnrollmentScreenBody({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fullName = buildFullName(profile);
    final userId = profile.userId;

    if (userId == null) {
      return const Center(
        child: Text('No student ID is available for the current user.'),
      );
    }

    final studentProfile = ref.watch(studentProfileProvider(userId));

    return studentProfile.when(
      loading: () => const AppLoadingScreen(),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (studentProfile) {
        final studentEnrollments = ref.watch(
          studentEnrollmentSummaryProvider(studentProfile.studentId),
        );

        return studentEnrollments.when(
          loading: () => const AppLoadingScreen(),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (summary) {
            final assignedSubjects = summary.enrollments
                .where((enrollment) => enrollment.enrollmentStatus == 0)
                .toList();
            final enrolledSubjects = summary.enrollments
                .where((enrollment) => enrollment.enrollmentStatus == 1)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
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
                        InfoRow(
                          label: 'Student ID',
                          value: studentProfile.studentId,
                        ),
                        InfoRow(label: 'Student Name', value: fullName),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _EnrollmentSection(
                        title: 'Assigned Subjects',
                        items: assignedSubjects,
                        studentId: studentProfile.studentId,
                        newStatus: 1,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _EnrollmentSection(
                        title: 'Enrolled Subjects',
                        items: enrolledSubjects,
                        studentId: studentProfile.studentId,
                        newStatus: 0,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EnrollmentSection extends ConsumerWidget {
  final String title;
  final List<EnrollmentItemsDTO> items;
  final String studentId;
  final int newStatus;

  const _EnrollmentSection({
    required this.title,
    required this.items,
    required this.studentId,
    required this.newStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No subjects found.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : CustomInkWellList(
                  onChildTap: (index) {
                    unawaited(
                      _updateEnrollmentStatus(
                        context,
                        ref,
                        index,
                        studentId,
                      ),
                    );
                  },
                  children: items
                      .map(
                        (enrollment) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                enrollment.subjectName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${enrollment.stubCode} • ${enrollment.formattedSchedule}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Future<void> _updateEnrollmentStatus(
    BuildContext context,
    WidgetRef ref,
    int index,
    String studentId,
  ) async {
    if (index < 0 || index >= items.length) {
      return;
    }

    final enrollment = items[index];

    try {
      final repository = ref.read(enrollmentRepositoryProvider);
      await repository.updateEnrollmentStatus(
        enrollmentId: enrollment.enrollmentId,
        newStatus: newStatus,
      );

      ref.invalidate(studentEnrollmentSummaryProvider(studentId));

      if (!context.mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 1
                ? 'Enrollment moved to Enrolled Subjects.'
                : 'Enrollment moved to Assigned Subjects.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update enrollment: $error')),
      );
    }
  }
}
