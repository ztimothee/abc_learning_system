import 'dart:async';

import 'package:abc_learning_system/features/student_records/controllers/student_records_repository.dart';
import 'package:abc_learning_system/features/student_records/models/grades_dto.dart';
import 'package:abc_learning_system/features/student_records/models/student_attendance_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentRecordsOperationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {
    // No initialization needed for now
    return null;
  }

  Future<void> submitAttendance(List<StudentAttendanceLog> rowsToUpdate, DateTime attendanceDate) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(studentRecordsRepositoryProvider);
      await repository.submitAttendanceSheet(logs: rowsToUpdate, attendanceDate: attendanceDate);
      ref.invalidate(studentRecordsRepositoryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitGrade(GradesDTO grade) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(studentRecordsRepositoryProvider);
      await repository.submitGradeForStudent(grade);
      ref.invalidate(studentRecordsRepositoryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final studentRecordsOperationControllerProvider =
    AsyncNotifierProvider<StudentRecordsOperationController, void>(
  () => StudentRecordsOperationController(),
);