import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:abc_learning_system/features/enrollments/controllers/enrollment_repository.dart';
import 'package:abc_learning_system/features/enrollments/models/tutor_subjects_dto.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:abc_learning_system/shared/tutors/controllers/tutor_repository.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tutorAssignedSubjectsProvider =
    FutureProvider.family<List<TutorSubjectsDTO>, String>((ref, tutorId) async {
      final repository = ref.watch(enrollmentRepositoryProvider);
      return repository.getAssignedSubjectsForTutorByTutorId(tutorId);
    });

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
  String _searchQuery = '';
  String? _selectedStubCode;

  String _subjectLabel(TutorSubjectsDTO subject) {
    final subjectName = subject.subjectName;
    final stubCode = subject.stubCode;
    return '$subjectName - $stubCode';
  }

  List<TutorSubjectsDTO> _filterSubjects(
    List<TutorSubjectsDTO> subjects,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return subjects;
    return subjects
        .where(
          (subject) => _subjectLabel(subject).toLowerCase().contains(trimmed),
        )
        .toList();
  }

  void _ensureSelectedSubject(List<TutorSubjectsDTO> subjects) {
    if (_selectedStubCode != null || subjects.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedStubCode = subjects.first.stubCode;
      });
    });
  }

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
            _ensureSelectedSubject(subjects);
            final filteredSubjects = _filterSubjects(subjects, _searchQuery);
            final selectedSubject = subjects.isEmpty
                ? null
                : subjects.firstWhere(
                    (subject) => subject.stubCode == _selectedStubCode,
                    orElse: () => subjects.first,
                  );
            final selectedLabel = selectedSubject == null
                ? 'No assigned subjects'
                : _subjectLabel(selectedSubject);

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
                        Text(
                          'Subject List',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (subjects.isEmpty)
                          Text(
                            'No subjects assigned yet.',
                            style: theme.textTheme.bodyMedium,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: subjects.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final subject = subjects[index];
                              final label = _subjectLabel(subject);
                              final isSelected =
                                  subject.stubCode == _selectedStubCode;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(label),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedStubCode = subject.stubCode;
                                  });
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Lists',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search subject name - stub code',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_searchQuery.trim().isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Matching Subjects',
                                style: theme.textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              if (filteredSubjects.isEmpty)
                                Text(
                                  'No subjects match the search.',
                                  style: theme.textTheme.bodySmall,
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredSubjects.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 12),
                                  itemBuilder: (context, index) {
                                    final subject = filteredSubjects[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(_subjectLabel(subject)),
                                      onTap: () {
                                        setState(() {
                                          _selectedStubCode = subject.stubCode;
                                        });
                                      },
                                    );
                                  },
                                ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        Row(
                          children: [
                            Text(
                              'Selected Subject:',
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedLabel,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_selectedStubCode == null ||
                            selectedSubject == null)
                          Text(
                            'Select a subject to view students.',
                            style: theme.textTheme.bodyMedium,
                          )
                        else
                          _StudentListTable(
                            subjectId: selectedSubject.subjectId,
                            stubCode: _selectedStubCode!,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StudentListTable extends ConsumerWidget {
  final String subjectId;
  final String stubCode;

  const _StudentListTable({required this.subjectId, required this.stubCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final students = ref.watch(
      classRosterProvider({'subjectId': subjectId, 'stubCode': stubCode}),
    );

    return students.when(
      loading: () => const AppLoadingScreen(),
      error: (error, stackTrace) =>
          Center(child: Text('Student List Error: $error')),
      data: (items) {
        if (items.isEmpty) {
          return Text(
            'No students found for this subject.',
            style: theme.textTheme.bodyMedium,
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Student Name',
                      style: theme.textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Student ID',
                      style: theme.textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Enroll Status',
                      style: theme.textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final student = items[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        student.fullName,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        student.displayId,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        student.enrollmentStatus.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
