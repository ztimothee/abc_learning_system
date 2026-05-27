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
            final leftLastName = _extractLastName(left.fullName);
            final rightLastName = _extractLastName(right.fullName);
            final lastNameComparison = leftLastName.compareTo(rightLastName);
            if (lastNameComparison != 0) {
              return lastNameComparison;
            }

            return _displayNameLastFirst(
              left.fullName,
            ).compareTo(_displayNameLastFirst(right.fullName));
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
                              _displayNameLastFirst(student.fullName),
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
                        student.enrollmentStatus.enrollmentStatus,
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

String _extractLastName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) {
    return '';
  }

  return parts.last.toLowerCase();
}

String _displayNameLastFirst(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || (parts.length == 1 && parts.first.isEmpty)) {
    return fullName;
  }

  if (parts.length == 1) {
    return parts.first;
  }

  final lastName = parts.last;
  final givenNames = parts.sublist(0, parts.length - 1).join(' ');
  return '$lastName, $givenNames';
}
