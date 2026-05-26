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

class StudentEnrollmentScreenBody extends ConsumerStatefulWidget {
  final Profile profile;
  const StudentEnrollmentScreenBody({super.key, required this.profile});

  @override
  ConsumerState<StudentEnrollmentScreenBody> createState() =>
      _StudentEnrollmentScreenBodyState();
}

class _StudentEnrollmentScreenBodyState
    extends ConsumerState<StudentEnrollmentScreenBody> {
  final Set<String> _pendingEnrollmentIds = {};

  Future<void> _confirmPendingEnrollments(String studentId) async {
    final pendingIds = _pendingEnrollmentIds.toList();
    if (pendingIds.isEmpty) return;

    try {
      final repository = ref.read(enrollmentRepositoryProvider);
      await repository.updateEnrollmentStatuses(
        enrollmentIds: pendingIds,
        newStatus: 1,
      );

      if (!mounted) return;
      setState(() {
        _pendingEnrollmentIds.clear();
      });

      ref.invalidate(studentEnrollmentSummaryProvider(studentId));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected subjects were added to enrolled subjects.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update enrollment: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
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
                .where(
                  (enrollment) =>
                      enrollment.enrollmentStatus == 0 &&
                      !_pendingEnrollmentIds.contains(enrollment.enrollmentId),
                )
                .toList();
            final enrolledSubjects = summary.enrollments
                .where(
                  (enrollment) =>
                      enrollment.enrollmentStatus == 0 &&
                      _pendingEnrollmentIds.contains(enrollment.enrollmentId),
                )
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
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('How to add subjects:', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                'Tap subjects in the Assigned Subjects list to stage them for enrollment.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                'Review staged subjects in the Enrolled Subjects panel on the right.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                'When ready, tap the "Add Selected Subjects" button to confirm enrollment.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assigned Subjects
                    Expanded(
                      child: _EnrollmentSection(
                        title: 'Assigned Subjects',
                        items: assignedSubjects,
                        onItemTap: (enrollment) {
                          setState(() {
                            _pendingEnrollmentIds.add(enrollment.enrollmentId);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Staged / Pending Subjects (middle)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EnrollmentSection(
                            title: 'Staged Subjects',
                            items: enrolledSubjects,
                            onItemTap: (enrollment) {
                              // toggle staging: tapping staged removes it
                              setState(() {
                                _pendingEnrollmentIds.remove(enrollment.enrollmentId);
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: enrolledSubjects.isEmpty
                                  ? null
                                  : () => _confirmPendingEnrollments(
                                        studentProfile.studentId,
                                      ),
                              icon: const Icon(Icons.add),
                              label: Text(
                                enrolledSubjects.isEmpty
                                    ? 'Add Selected Subjects'
                                    : 'Add Selected Subjects (${enrolledSubjects.length})',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Confirmed Subjects (status == 1)
                    Expanded(
                      child: _EnrollmentSection(
                        title: 'Confirmed Subjects',
                        items: summary.enrollments
                            .where((e) => e.enrollmentStatus == 1)
                            .toList(),
                        onItemTap: null, // unclickable
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

class _EnrollmentSection extends StatelessWidget {
  final String title;
  final List<EnrollmentItemsDTO> items;
  final ValueChanged<EnrollmentItemsDTO>? onItemTap;

  const _EnrollmentSection({
    required this.title,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'No subjects found.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              : CustomInkWellList(
                  onChildTap: (index) {
                    if (onItemTap == null) {
                      return;
                    }

                    onItemTap!(items[index]);
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
}
