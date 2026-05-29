import 'package:abc_learning_system/core/themes/status_map.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentListTable extends ConsumerWidget {
  final String subjectId;
  final String stubCode;

  const StudentListTable({
    super.key,
    required this.subjectId,
    required this.stubCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    debugPrint(
      'Loading students for subjectId: $subjectId, stubCode: $stubCode',
    );
    final students = ref.watch(
      classRosterProvider((subjectId: subjectId, stubCode: stubCode)),
    );
    debugPrint(
      'Watched classRosterProvider for subjectId: $subjectId, stubCode: $stubCode',
    );

    return students.when(
      loading: () => const AppLoadingScreen(),
      error: (error, stackTrace) =>
          Center(child: Text('Student List Error: $error')),
      data: (items) {
        final sortedItems = [...items]
          ..sort((left, right) {
            // Use the already-formatted fullName from ClassRosterViewDTO
            return left.fullName.compareTo(right.fullName);
          });

        if (sortedItems.isEmpty) {
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
              itemCount: sortedItems.length,
              separatorBuilder: (_, __) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final student = sortedItems[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${index + 1}.',
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              student.fullName,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
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
                        student.enrollmentStatus.enrollmentStatusString,
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
