import 'package:abc_learning_system/core/themes/status_map.dart';
import 'package:abc_learning_system/features/student_records/controllers/attendance_sheet_notifier.dart';
import 'package:abc_learning_system/features/student_records/controllers/student_records_operation_controller.dart';
import 'package:abc_learning_system/features/student_records/models/student_attendance_log.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AttendanceSheetTable extends ConsumerStatefulWidget {
  final String subjectId;
  final String stubCode;

  const AttendanceSheetTable({
    super.key,
    required this.subjectId,
    required this.stubCode,
  });

  @override
  ConsumerState<AttendanceSheetTable> createState() =>
      _AttendanceSheetTableState();
}

class _AttendanceSheetTableState extends ConsumerState<AttendanceSheetTable> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshSheet();
  }

  void _refreshSheet() {
    Future.microtask(() {
      ref
          .read(attendanceSheetProvider.notifier)
          .fetchSheet(
            subjectId: widget.subjectId,
            stubCode: widget.stubCode,
            date: _selectedDate,
          );
    });
  }

  void _cycleStatus(StudentAttendanceLog student) {
    final nextStatus = student.status >= 4 ? 0 : student.status + 1;
    ref
        .read(attendanceSheetProvider.notifier)
        .updateStatus(student.enrollmentId, nextStatus);
  }

  Future<void> _submitAttendanceData(
    List<StudentAttendanceLog> workingList,
  ) async {
    await ref
        .read(studentRecordsOperationControllerProvider.notifier)
        .submitAttendance(workingList, _selectedDate);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Submitted attendance for ${workingList.length} students.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceSheetProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Attendance Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() => _selectedDate = picked);
                      _refreshSheet();
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Change Date'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: attendanceState.when(
            loading: () => const AppLoadingScreen(),
            error: (error, _) =>
                Center(child: Text('Attendance Error: $error')),
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Text(
                    'No active student rosters found for this class.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
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
                            'Attendance',
                            style: theme.textTheme.labelLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                student.studentName,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                student.studentDisplayId,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: TextButton(
                                  onPressed: () => _cycleStatus(student),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        student.status.attendanceStatusColor,
                                  ),
                                  child: Text(
                                    student.status.attendanceStatusString,
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
                  FilledButton.icon(
                    onPressed: () => _submitAttendanceData(students),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Submit Attendance'),
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
