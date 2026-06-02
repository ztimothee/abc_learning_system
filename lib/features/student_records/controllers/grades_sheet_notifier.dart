import 'package:abc_learning_system/features/student_records/controllers/student_records_repository.dart';
import 'package:abc_learning_system/features/student_records/models/class_student_grade_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// Import your repository layer and ClassStudentGradeDTO here

class GradesSheetNotifier extends StateNotifier<AsyncValue<List<ClassStudentGradeDTO>>> {
  final StudentRecordsRepository _repository; 

  GradesSheetNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchSheet({required String subjectId, required String stubCode}) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.fetchClassGrades(
        subjectId: subjectId, 
        stubCode: stubCode,
      );
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final gradesSheetProvider = StateNotifierProvider<GradesSheetNotifier, AsyncValue<List<ClassStudentGradeDTO>>>((ref) {
  // Replace with your real repository provider call
  final repo = ref.watch(studentRecordsRepositoryProvider); 
  return GradesSheetNotifier(repo);
});