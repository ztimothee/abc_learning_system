import 'package:abc_learning_system/features/enrollments/controllers/enrollment_operation_controller.dart';
import 'package:abc_learning_system/features/enrollments/controllers/enrollment_repository.dart';
import 'package:abc_learning_system/features/enrollments/models/batched_subjects_dto.dart';
import 'package:abc_learning_system/features/enrollments/models/enrollment_items_dto.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/bordered_surface.dart';
import 'package:abc_learning_system/shared/widgets/bulleted_instructions_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffEnrollmentScreen extends ConsumerStatefulWidget {
  const StaffEnrollmentScreen({super.key});

  @override
  ConsumerState<StaffEnrollmentScreen> createState() =>
      _StaffEnrollmentScreenState();
}

class _StaffEnrollmentScreenState extends ConsumerState<StaffEnrollmentScreen> {
  final TextEditingController _displayIdController = TextEditingController();
  String _searchedDisplayId = '';
  List<SubjectDTO> _stagedSubjects = [];
  final Set<String> _stagedBatchIds = <String>{};
  bool _isAssigningSubjects = false;

  @override
  void dispose() {
    _displayIdController.dispose();
    super.dispose();
  }

  void _searchStudent() {
    final displayId = _displayIdController.text.trim();
    setState(() {
      _searchedDisplayId = displayId;
      _stagedSubjects = [];
      _stagedBatchIds.clear();
    });
  }

  void _stageBatch(BatchedSubjectsDTO batch) {
    setState(() {
      _stagedBatchIds.add(batch.batchId);
      final stagedIds = _stagedSubjects
          .map((subject) => subject.subjectId)
          .toSet();
      final mergedSubjects = <SubjectDTO>[..._stagedSubjects];

      for (final subject in batch.subjects) {
        if (stagedIds.add(subject.subjectId)) {
          mergedSubjects.add(subject);
        }
      }

      _stagedSubjects = mergedSubjects;
    });
  }

  Future<void> _assignStagedSubjects(String studentId) async {
    if (_stagedBatchIds.isEmpty || _isAssigningSubjects) {
      return;
    }

    setState(() {
      _isAssigningSubjects = true;
    });

    try {
      final controller = ref.read(
        enrollmentOperationControllerProvider.notifier,
      );
      for (final batchId in _stagedBatchIds) {
        await controller.batchEnrollStudentInSubjects(studentId, batchId);
      }

      if (mounted) {
        setState(() {
          _stagedSubjects = [];
          _stagedBatchIds.clear();
        });
      }
    } catch (e) {
      debugPrint('Error enrolling subjects: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error enrolling subjects: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigningSubjects = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmedDisplayId = _searchedDisplayId.trim();
    final studentProfileAsync = trimmedDisplayId.isEmpty
        ? null
        : ref.watch(studentProfileByDisplayIdProvider(trimmedDisplayId));
    final batchedSubjectsAsync = ref.watch(allBatchedSubjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Enrollment')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BulletedInstructionsCard(
              title: 'Staff enrollment flow',
              instructions: [
                'Search a student using the display ID to load their current subjects.',
                'Tap a batch to stage all of its subjects for the selected student.',
                'Use Add Subjects to assign the staged subjects to the student.',
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _displayIdController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchStudent(),
              decoration: InputDecoration(
                labelText: 'Student Display ID',
                hintText: 'Enter display ID and press Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search student',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _searchStudent,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (trimmedDisplayId.isNotEmpty)
              studentProfileAsync!.when(
                loading: () => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: BorderedSurface(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Loading student details...'),
                        ],
                      ),
                    ),
                  ),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: BorderedSurface(
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Student search error: $error',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                data: (studentProfile) {
                  final profile = studentProfile.profile;
                  final fullName = [
                    profile?.firstName ?? '',
                    profile?.middleName ?? '',
                    profile?.lastName ?? '',
                  ].where((part) => part.trim().isNotEmpty).join(' ');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: BorderedSurface(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student Name',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fullName.isEmpty
                                        ? 'Unnamed student'
                                        : fullName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Display ID',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    studentProfile.displayId,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (trimmedDisplayId.isEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PanelShell(
                      title: 'Current Subjects',
                      child: _EmptyPanelMessage(
                        message:
                            'Search a student to display current subjects.',
                        theme: theme,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PanelShell(
                      title: 'Staged Subjects',
                      footer: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: null,
                          child: const Text('Add Subjects'),
                        ),
                      ),
                      child: _EmptyPanelMessage(
                        message: 'Select a batch to stage its subjects.',
                        theme: theme,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PanelShell(
                      title: 'Subject Batches',
                      footer: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: null,
                          child: const Text('Add Batch'),
                        ),
                      ),
                      child: batchedSubjectsAsync.when(
                        loading: () => const AppLoadingScreen(),
                        error: (error, stackTrace) => Text(
                          'Batch List Error: $error',
                          style: theme.textTheme.bodyMedium,
                        ),
                        data: (batches) => _BatchList(
                          batches: batches,
                          onBatchTap: _stageBatch,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              studentProfileAsync!.when(
                loading: () => const AppLoadingScreen(),
                error: (error, stackTrace) => Text(
                  'Student search error: $error',
                  style: theme.textTheme.bodyMedium,
                ),
                data: (studentProfile) {
                  final studentEnrollmentAsync = ref.watch(
                    studentEnrollmentSummaryProvider(studentProfile.studentId),
                  );

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _PanelShell(
                          title: 'Current Subjects',
                          child: studentEnrollmentAsync.when(
                            loading: () => const AppLoadingScreen(),
                            error: (error, stackTrace) => Text(
                              'Current Subjects Error: $error',
                              style: theme.textTheme.bodyMedium,
                            ),
                            data: (summary) {
                              final currentEnrollments = summary.enrollments
                                  .where(
                                    (enrollment) =>
                                        enrollment.enrollmentStatus == 0,
                                  )
                                  .toList();

                              if (currentEnrollments.isEmpty) {
                                return _EmptyPanelMessage(
                                  message:
                                      'Search a student to display current subjects.',
                                  theme: theme,
                                );
                              }

                              return _EnrollmentList(items: currentEnrollments);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PanelShell(
                          title: 'Staged Subjects',
                          footer: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed:
                                  _stagedBatchIds.isEmpty ||
                                      _isAssigningSubjects
                                  ? null
                                  : () => _assignStagedSubjects(
                                      studentProfile.studentId,
                                    ),
                              child: _isAssigningSubjects
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Add Subjects'),
                            ),
                          ),
                          child: _StagedSubjectsList(
                            stagedSubjects: _stagedSubjects,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PanelShell(
                          title: 'Subject Batches',
                          footer: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: null,
                              child: const Text('Add Batch'),
                            ),
                          ),
                          child: batchedSubjectsAsync.when(
                            loading: () => const AppLoadingScreen(),
                            error: (error, stackTrace) => Text(
                              'Batch List Error: $error',
                              style: theme.textTheme.bodyMedium,
                            ),
                            data: (batches) => _BatchList(
                              batches: batches,
                              onBatchTap: _stageBatch,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PanelShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;

  const _PanelShell({required this.title, required this.child, this.footer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BorderedSurface(
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
        ),
        BorderedSurface(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
        if (footer != null) ...[const SizedBox(height: 12), footer!],
      ],
    );
  }
}

class _EmptyPanelMessage extends StatelessWidget {
  final String message;
  final ThemeData theme;

  const _EmptyPanelMessage({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        message,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EnrollmentList extends StatelessWidget {
  final List<EnrollmentItemsDTO> items;

  const _EnrollmentList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subjectName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stub Code: ${item.stubCode}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${item.enrollmentStatus}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StagedSubjectsList extends StatelessWidget {
  final List<SubjectDTO> stagedSubjects;

  const _StagedSubjectsList({required this.stagedSubjects});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (stagedSubjects.isEmpty) {
      return Text(
        'Select a batch to stage subjects.',
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      );
    }

    return Column(
      children: stagedSubjects
          .map(
            (subject) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.subjectName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Subject ID: ${subject.subjectId}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BatchList extends StatelessWidget {
  final List<BatchedSubjectsDTO> batches;
  final ValueChanged<BatchedSubjectsDTO> onBatchTap;

  const _BatchList({required this.batches, required this.onBatchTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (batches.isEmpty) {
      return Text(
        'No batches found.',
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      );
    }

    return Column(
      children: batches
          .map(
            (batch) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onBatchTap(batch),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.batchName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${batch.subjects.length} subjects',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
