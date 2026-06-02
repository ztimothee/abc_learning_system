import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:abc_learning_system/features/enrollments/controllers/enrollment_repository.dart';
import 'package:abc_learning_system/features/enrollments/models/tutor_subjects_dto.dart';
import 'package:abc_learning_system/shared/tutors/controllers/tutor_repository.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/bordered_list.dart';
import 'package:abc_learning_system/shared/widgets/bordered_surface.dart';
import 'package:abc_learning_system/shared/widgets/bulleted_instructions_card.dart';
import 'package:abc_learning_system/shared/widgets/header_card.dart';
import 'package:abc_learning_system/features/student_records/screens/widgets/attendance_sheet_table.dart';
// Make sure to adjust this import path to where you place the new widget
import 'package:abc_learning_system/features/student_records/screens/widgets/grades_sheet_table.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorStudentRecordsScreen extends ConsumerWidget {
  const TutorStudentRecordsScreen({super.key});

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

          return TutorStudentRecordsBody(profile: data);
        },
      ),
    );
  }
}

class TutorStudentRecordsBody extends ConsumerStatefulWidget {
  final Profile profile;

  const TutorStudentRecordsBody({super.key, required this.profile});

  @override
  ConsumerState<TutorStudentRecordsBody> createState() =>
      _TutorStudentRecordsBodyState();
}

class _TutorStudentRecordsBodyState
    extends ConsumerState<TutorStudentRecordsBody> {
  TutorSubjectsDTO? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final theme = Theme.of(context);
    final fullName = buildFullNameSurnameFirst(
      profile.firstName,
      profile.middleName,
      profile.lastName,
    );
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
            final rosterHeight = (MediaQuery.of(context).size.height * 0.72)
                .clamp(520.0, 900.0)
                .toDouble();

            // Wrapped inside DefaultTabController to orchestrate the TabBar and TabBarView
            return DefaultTabController(
              length: 2,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Tutor Student Records',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  HeaderCard(
                    title: 'Student Records',
                    id: tutor.displayId,
                    name: fullName,
                  ),
                  const SizedBox(height: 20),
                  
                  // Tab Navigation Layout
                  Material(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.colorScheme.primaryContainer,
                      ),
                      labelColor: theme.colorScheme.onPrimaryContainer,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.assignment_turned_in_outlined),
                          text: 'Attendance Tracking',
                        ),
                        Tab(
                          icon: Icon(Icons.grade_outlined),
                          text: 'Grade Encoding',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Tab content wrapper box
                  SizedBox(
                    height: rosterHeight + 180, // Accommodates dynamic components safely
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(), // Prevents swipe gesture conflicts with internal tables
                      children: [
                        // TAB 1: ATTENDANCE WORKSPACE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BulletedInstructionsCard(
                              title: 'How to record attendance:',
                              instructions: [
                                'Tap a subject in the Assigned Subjects list to load its attendance sheet.',
                                'Use the date selector in the attendance panel to open the class sheet for another day.',
                                'Tap each student\'s attendance status button to cycle through states.',
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Row(
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
                                      children: [
                                        _buildPanelHeader(theme, 'Class Roster'),
                                        Expanded(
                                          child: _selectedSubject == null
                                              ? _buildEmptyStatePlaceholder(theme)
                                              : AttendanceSheetTable(
                                                  key: ValueKey(
                                                    'attendance:${_selectedSubject!.subjectId}:${_selectedSubject!.stubCode}',
                                                  ),
                                                  subjectId: _selectedSubject!.subjectId,
                                                  stubCode: _selectedSubject!.stubCode,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // TAB 2: GRADE ENCODING WORKSPACE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BulletedInstructionsCard(
                              title: 'How to encode grades:',
                              instructions: [
                                'Tap a subject in the Assigned Subjects list to view its grade sheets.',
                                'Select the desired academic terms/grading period using the selection panel dropdown.',
                                'Input correct grade numeric marks into each respective field and click Save changes.',
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Row(
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
                                      children: [
                                        _buildPanelHeader(theme, 'Grade Registry'),
                                        Expanded(
                                          child: _selectedSubject == null
                                              ? _buildEmptyStatePlaceholder(theme)
                                              : GradesSheetTable(
                                                  key: ValueKey(
                                                    'grades:${_selectedSubject!.subjectId}:${_selectedSubject!.stubCode}',
                                                  ),
                                                  subjectId: _selectedSubject!.subjectId,
                                                  stubCode: _selectedSubject!.stubCode,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPanelHeader(ThemeData theme, String title) {
    return BorderedSurface(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEmptyStatePlaceholder(ThemeData theme) {
    return BorderedSurface(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          'Select a subject to display the respective class roster details',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}