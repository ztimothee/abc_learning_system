import 'package:abc_learning_system/features/student_records/models/class_student_grade_dto.dart';
import 'package:abc_learning_system/features/student_records/models/grades_dto.dart';
import 'package:abc_learning_system/features/student_records/models/student_attendance_log.dart';
import 'package:abc_learning_system/features/student_records/models/student_grades_report_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRecordsRepository {
  final SupabaseClient supabase;

  StudentRecordsRepository({required this.supabase});

  Future<List<StudentAttendanceLog>> loadAttendanceSheet({
    required String subjectId,
    required String stubCode,
    required DateTime selectedDate,
  }) async {
    // Format target date to match the database date format (YYYY-MM-DD)
    final String dateString = selectedDate.toIso8601String().split('T')[0];

    // 1. Always pull from the roster view so you get every confirmed student
    final List<Map<String, dynamic>> response = await supabase
        .from('class_roster_view')
        .select('''
          enrollment_id,
          display_id,
          first_name,
          last_name,
          status,
          attendances(
            status
          )
        ''')
        .eq('subject_id', subjectId)
        .eq('stub_code', stubCode)
        .eq('status', 1) // Only pull active/confirmed students
        // Sub-filter: Grab attendance for this student ONLY matching today's date day
        .eq('attendances.attendance_date', dateString);

    // 2. Map cleanly into your uniform UI state list
    return response.map((data) => StudentAttendanceLog.fromMap(data)).toList();
  }

  Future<List<StudentGradesReportDTO>> fetchStudentGrades(String studentId) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('enrollments')
          .select('''
            enrollment_id,
            status,
            subjects (
              subject_name,
              subject_assignments (
                stub_code
              )
            ),
            grades (
              final_grade,
              remarks
            )
          ''')
          .eq('student_id', studentId)
          .eq('status', 1); // Only show active confirmed enrollments

      return response.map((data) => StudentGradesReportDTO.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error fetching grade report with stubs: $e');
      return [];
    }
  }

  Future<List<ClassStudentGradeDTO>> fetchClassGrades({
    required String subjectId,
    required String stubCode,
  }) async {
    try {
      // Querying the view directly simplifies the nested joins down to a flat selection
      final List<Map<String, dynamic>> response = await supabase
          .from('class_roster_view')
          .select('''
            enrollment_id,
            display_id,
            first_name,
            last_name,
            status,
            grades (
              final_grade,
              remarks
            )
          ''')
          .eq('subject_id', subjectId)
          .eq('stub_code', stubCode)
          .eq('status', 1); // Only active confirmed enrollments

      return response.map((data) => ClassStudentGradeDTO.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Database Error in fetchClassGrades via View: $e');
      rethrow;
    }
  }

  // ========= Attendance Submission Logic =======================================================================================

  Future<void> submitAttendanceSheet({
    required List<StudentAttendanceLog> logs,
    required DateTime attendanceDate,
  }) async {
    if (logs.isEmpty) return;

    final String formattedDate = attendanceDate.toIso8601String().split('T')[0]; // YYYY-MM-DD

    // 1. Map your UI state objects into raw Postgres modification parameters
    final List<Map<String, dynamic>> rowsToUpdate = logs.map((log) {
      return {
        'enrollment_id': log.enrollmentId,
        'status': log.status, 
        'attendance_date': formattedDate,
      };
    }).toList();

    // 2. Perform a single batch update using upsert
    await supabase
        .from('attendances')
        .upsert(
          rowsToUpdate,
          onConflict: 'enrollment_id, attendance_date', // Ensure uniqueness per student per day
        );
  }

  Future<void> submitGradeForStudent(GradesDTO grade) async {
    await supabase
        .from('grades')
        .upsert({
          'enrollment_id': grade.enrollmentId,
          'final_grade': grade.finalGrade,
          'remarks': grade.remarks,
        }, onConflict: 'enrollment_id'); // Ensure one grade per enrollment
  }

  Future<void> submitBulkClassGrades(List<Map<String, dynamic>> gradeRecords) async {
    await supabase
        .from('grades')
        .upsert(gradeRecords); // Removed onConflict override target completely
  }
}

final studentRecordsRepositoryProvider = Provider<StudentRecordsRepository>(
  (ref) => StudentRecordsRepository(supabase: Supabase.instance.client),
);

final loadAttendanceSheetProvider = FutureProvider.family<
    List<StudentAttendanceLog>, Map<String, dynamic>>(
  (ref, params) async {
    final repository = ref.read(studentRecordsRepositoryProvider);
    return repository.loadAttendanceSheet(
      subjectId: params['subjectId'],
      stubCode: params['stubCode'],
      selectedDate: params['selectedDate'],
    );
  },
);

final fetchStudentGradesProvider = FutureProvider.family<
    List<StudentGradesReportDTO>, String>(
  (ref, studentId) async {
    final repository = ref.read(studentRecordsRepositoryProvider);
    return repository.fetchStudentGrades(studentId);
  },
);