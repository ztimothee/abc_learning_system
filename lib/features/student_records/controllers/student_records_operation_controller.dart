import 'dart:async';

import 'package:abc_learning_system/features/student_records/controllers/student_records_repository.dart';
import 'package:abc_learning_system/features/student_records/models/student_attendance_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentRecordsOperationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {
    // No initialization needed for now
    return null;
  }

  Future<void> preGenerateSemesterAttendance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(studentRecordsRepositoryProvider);
      await repository.preGenerateSemesterAttendance(
        startDate: startDate,
        endDate: endDate,
      );
      ref.invalidate(studentRecordsRepositoryProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> submitAttendance(List<StudentAttendanceLog> rowsToUpdate) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(studentRecordsRepositoryProvider);
      await repository.submitAttendanceSheet(logs: rowsToUpdate);
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