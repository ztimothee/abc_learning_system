import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:abc_learning_system/features/enrollments/controllers/enrollment_repository.dart';
import 'package:abc_learning_system/features/enrollments/models/tutor_subjects_dto.dart';
import 'package:abc_learning_system/features/enrollments/screens/widgets/student_list_table.dart';
import 'package:abc_learning_system/shared/widgets/bordered_list.dart';
import 'package:abc_learning_system/shared/tutors/controllers/tutor_repository.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/bulleted_instructions_card.dart';
import 'package:abc_learning_system/shared/widgets/bordered_surface.dart';
import 'package:abc_learning_system/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorEnrollmentScreen extends ConsumerWidget {
  const TutorEnrollmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      body: profile.when(
        loading: () => const AppLoadingScreen(),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (data) {
          if (data == null) {
            return const Center(
              child: Text(
                'No tutor profile is available for the current user.',
              ),
            );
          }

          return TutorEnrollmentScreenBody(profile: data);
        },
      ),
    );
  }
}

class TutorEnrollmentScreenBody extends ConsumerStatefulWidget {
  final Profile profile;

  const TutorEnrollmentScreenBody({super.key, required this.profile});

  @override
  ConsumerState<TutorEnrollmentScreenBody> createState() =>
      _TutorEnrollmentScreenBodyState();
}

class _TutorEnrollmentScreenBodyState
    extends ConsumerState<TutorEnrollmentScreenBody> {
  TutorSubjectsDTO? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final theme = Theme.of(context);
    final fullName = buildFullName(profile);
    final userId = profile.userId;

    if (userId == null || userId.isEmpty) {
      return const Center(
        child: Text('No tutor user ID is available for the current user.'),
      );
    }

    final tutorProfile = ref.watch(tutorProfileByUserIdProvider(userId));
    return tutorProfile.when(
      loading: () => const AppLoadingScreen(),
      error: (error, stackTrace) =>
          Center(child: Text('Tutor Profile Error: $error')),
      data: (tutor) {
        debugPrint('Tutor profile loaded: ${tutor.tutorId}, $fullName');
        final assignedSubjects = ref.watch(
          tutorAssignedSubjectsProvider(tutor.tutorId),
        );
        debugPrint(
          'Assigned subjects for tutor ${tutor.tutorId}: $assignedSubjects',
        );

        return assignedSubjects.when(
          loading: () => const AppLoadingScreen(),
          error: (error, stackTrace) =>
              Center(child: Text('Subject List Error: $error')),
          data: (subjects) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Enrollees Master List',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
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
                        InfoRow(label: 'Teacher ID', value: userId),
                        InfoRow(label: 'Teacher Name', value: fullName),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BulletedInstructionsCard(
                  title: 'How to view class roster:',
                  instructions: [
                    'Tap subjects in the Assigned Subjects list to load their rosters.',
                    'The roster will display all students enrolled in that subject, along with their enrollment status.',
                    'Enrollment status codes: 0 = Admin-Assigned, 1 = Confirmed, 2 = Paid.',
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BorderedListView(
                      title: 'Assigned Subjects',
                      items: subjects,
                      onItemTap: (index) {
                        setState(() {
                          _selectedSubject = subjects[index];
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BorderedSurface(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Class Roster',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          if (_selectedSubject == null)
                            BorderedSurface(
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Select a subject to display the respective class roster',
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          else
                            StudentListTable(
                              subjectId: _selectedSubject!.subjectId,
                              stubCode: _selectedSubject!.stubCode,
                            ),
                        ],
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
