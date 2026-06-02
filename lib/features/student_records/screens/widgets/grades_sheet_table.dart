import 'package:abc_learning_system/features/student_records/controllers/grades_sheet_notifier.dart';
import 'package:abc_learning_system/features/student_records/controllers/student_records_operation_controller.dart';
import 'package:abc_learning_system/features/student_records/models/class_student_grade_dto.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GradesSheetTable extends ConsumerStatefulWidget {
  final String subjectId;
  final String stubCode;

  const GradesSheetTable({
    super.key,
    required this.subjectId,
    required this.stubCode,
  });

  @override
  ConsumerState<GradesSheetTable> createState() => _GradesSheetTableState();
}

class _GradesSheetTableState extends ConsumerState<GradesSheetTable> {
  // Local controllers cache map to avoid focus disruptions while editing fields
  final Map<String, TextEditingController> _gradeControllers = {};
  final Map<String, TextEditingController> _remarksControllers = {};

  @override
  void initState() {
    super.initState();
    _refreshGradeSheet();
  }

  @override
  void dispose() {
    for (var c in _gradeControllers.values) {
      c.dispose();
    }
    for (var c in _remarksControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _refreshGradeSheet() {
    Future.microtask(() {
      ref.read(gradesSheetProvider.notifier).fetchSheet(
            subjectId: widget.subjectId,
            stubCode: widget.stubCode,
          );
    });
  }

  Future<void> _processSubmission(List<ClassStudentGradeDTO> currentRoster) async {
    debugPrint('Processing grade submission for ${currentRoster.length} students...');

    final List<Map<String, dynamic>> payload = [];

    debugPrint('Iterating through students to build payload...');

    for (var student in currentRoster) {
      debugPrint('Processing student: ${student.studentName} (Enrollment ID: ${student.enrollmentId})');

      final gradeInput = _gradeControllers[student.enrollmentId]?.text;
      final remarksInput = _remarksControllers[student.enrollmentId]?.text ?? '';

      final Map<String, dynamic> gradeRow = {
        'enrollment_id': student.enrollmentId,
        'final_grade': gradeInput != null && gradeInput.isNotEmpty ? int.tryParse(gradeInput) : null,
        'remarks': remarksInput,
      };

      // If we already fetched a grade_id for this student, attach it!
      if (student.gradeId != null) {
        debugPrint('Existing grade record found for ${student.studentName}, including grade_id: ${student.gradeId}');
        gradeRow['grade_id'] = student.gradeId;
      }

      debugPrint('Constructed grade row for ${student.studentName}: $gradeRow');

      payload.add(gradeRow);
    }

    final repository = ref.read(studentRecordsOperationControllerProvider.notifier);
    await repository.submitGrades(payload);
  }

  @override
  Widget build(BuildContext context) {
    final gradesState = ref.watch(gradesSheetProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: gradesState.when(
            loading: () => const AppLoadingScreen(),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Grades System Error: $error', textAlign: TextAlign.center),
              ),
            ),
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Text(
                    'No active rosters found for grade tracking.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                children: [
                  // Table Row Headers
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Student Name', style: theme.textTheme.labelLarge, textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('Student ID', style: theme.textTheme.labelLarge, textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('Final Grade', style: theme.textTheme.labelLarge, textAlign: TextAlign.center)),
                        Expanded(flex: 3, child: Text('Remarks', style: theme.textTheme.labelLarge, textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Interactive Form List Builder Block
                  Expanded(
                    child: ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final student = students[index];

                        final gradeCtrl = _gradeControllers.putIfAbsent(
                          student.enrollmentId,
                          () => TextEditingController(text: student.finalGrade?.toString() ?? ''),
                        );
                        final remarksCtrl = _remarksControllers.putIfAbsent(
                          student.enrollmentId,
                          () => TextEditingController(text: student.remarks),
                        );

                        return Row(
                          children: [
                            Expanded(flex: 3, child: Text(student.studentName, textAlign: TextAlign.center)),
                            Expanded(flex: 2, child: Text(student.studentDisplayId, textAlign: TextAlign.center)),
                            
                            // Grade Input Text Form Box
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: SizedBox(
                                  width: 70,
                                  height: 40,
                                  child: TextField(
                                    controller: gradeCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Grade Remarks Summary Text Form Box
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    controller: remarksCtrl,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      hintText: 'Pass / Fail / Notes',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Collective Bulk Save Action Button
                  FilledButton.icon(
                    onPressed: () => _processSubmission(students),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Registry Changes'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}