import 'package:abc_learning_system/features/student_records/controllers/student_records_repository.dart';
import 'package:abc_learning_system/features/student_records/models/student_attendance_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// Import your model and repository location here

class AttendanceSheetNotifier extends StateNotifier<AsyncValue<List<StudentAttendanceLog>>> {
  final StudentRecordsRepository _repository; // Replace with your actual repo provider

  AttendanceSheetNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchSheet({
    required String subjectId,
    required String stubCode,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.loadAttendanceSheet(
        subjectId: subjectId,
        stubCode: stubCode,
        selectedDate: date,
      );
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // 💡 Mutate the item state locally inside RAM instantly
  void updateStatus(String enrollmentId, int newStatus) {
    state.whenData((currentList) {
      state = AsyncValue.data(
        currentList.map((student) {
          if (student.enrollmentId == enrollmentId) {
            student.status = newStatus;
          }
          return student;
        }).toList(),
      );
    });
  }
}

final attendanceSheetProvider = StateNotifierProvider<AttendanceSheetNotifier, AsyncValue<List<StudentAttendanceLog>>>(
  (ref) {
    final repository = ref.watch(studentRecordsRepositoryProvider);
    return AttendanceSheetNotifier(repository);
  },
);