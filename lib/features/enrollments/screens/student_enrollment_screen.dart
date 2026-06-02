import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:abc_learning_system/features/enrollments/controllers/enrollment_operation_controller.dart';
import 'package:abc_learning_system/features/enrollments/controllers/enrollment_repository.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/bordered_list.dart';
import 'package:abc_learning_system/shared/widgets/bulleted_instructions_card.dart';
import 'package:abc_learning_system/shared/widgets/header_card.dart';
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
      final controller = ref.read(
        enrollmentOperationControllerProvider.notifier,
      );
      await controller.updateMultipleEnrollmentStatus(studentId, pendingIds, 1);

      if (!mounted) return;

      ref.invalidate(studentEnrollmentSummaryProvider(studentId));
      setState(() {
        _pendingEnrollmentIds.clear();
      });

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
    final fullName = buildFullNameSurnameFirst(
      profile.firstName,
      profile.middleName,
      profile.lastName,
    );
    final userId = profile.userId;

    if (userId == null) {
      return const Center(
        child: Text('No student ID is available for the current user.'),
      );
    }

    debugPrint('Building StudentEnrollmentScreenBody for userId: $userId');
    final studentProfile = ref.watch(studentProfileByUserIdProvider(userId));

    debugPrint(
      'Watched studentProfileProvider for userId: $userId, value: $studentProfile',
    );
    return studentProfile.when(
      loading: () => const AppLoadingScreen(),
      error: (error, stackTrace) =>
          Center(child: Text('Profile Error: $error')),
      data: (studentProfile) {
        final studentEnrollments = ref.watch(
          studentEnrollmentSummaryProvider(studentProfile.studentId),
        );

        return studentEnrollments.when(
          loading: () => const AppLoadingScreen(),
          error: (error, stackTrace) =>
              Center(child: Text('Enrollments Error: $error')),
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
                HeaderCard(
                  title: 'Student Enrollment',
                  id: studentProfile.displayId,
                  name: fullName,
                ),
                const SizedBox(height: 20),
                BulletedInstructionsCard(
                  title: 'Enrollment Instructions',
                  instructions: [
                    'Tap subjects in the Assigned Subjects list to stage them for enrollment.',
                    'Review staged subjects in the Staged Subjects panel in the middle.',
                    'When ready, tap the "Add Selected Subjects" button to confirm enrollment.',
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assigned Subjects
                    BorderedListView(
                      title: 'Assigned Subjects',
                      items: assignedSubjects,
                      onItemTap: (index) {
                        setState(() {
                          _pendingEnrollmentIds.add(
                            assignedSubjects[index].enrollmentId,
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 12),

                    // Staged / Pending Subjects (middle)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BorderedListView(
                            title: 'Staged Subjects',
                            items: enrolledSubjects,
                            expand: false,
                            onItemTap: (index) {
                              // toggle staging: tapping staged removes it
                              setState(() {
                                _pendingEnrollmentIds.remove(
                                  enrolledSubjects[index].enrollmentId,
                                );
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
                    BorderedListView(
                      title: 'Confirmed Subjects',
                      items: summary.enrollments
                          .where((e) => e.enrollmentStatus == 1)
                          .toList(),
                      onItemTap: null, // unclickable
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
