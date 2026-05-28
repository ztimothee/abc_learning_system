import 'package:abc_learning_system/features/student_records/models/student_attendance_log.dart';
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
    // 1. Format the date to target the boundaries of that specific calendar day
    final String dateString = selectedDate.toIso8601String().split('T')[0];
    final String startOfDay = '${dateString}T00:00:00.000Z';
    final String endOfDay = '${dateString}T23:59:59.999Z';

    // 2. Query the pre-generated rows from the attendances table
    final List<Map<String, dynamic>> response = await supabase
        .from('attendances')
        .select('''
          attendance_id,
          status,
          enrollments!inner (
            enrollment_id,
            subject_id,
            subjects!inner (
              subject_assignments!inner (
                stub_code
              )
            ),
            students (
              display_id,
              profiles (
                first_name,
                middle_name,
                last_name
              )
            )
          )
        ''')
        // 3. Filter for this exact class section instance
        .eq('enrollments.subject_id', subjectId)
        .eq('enrollments.subjects.subject_assignments.stub_code', stubCode)
        // 4. Target the specific day's timeframe block
        .gte('attendance_date', startOfDay) // Greater than or equal to start of day
        .lte('attendance_date', endOfDay); // Less than or equal to end of day

    // 5. Safely map them using the new factory constructor
    return response.map((data) => StudentAttendanceLog.fromPreGenMap(data)).toList();
  }

  // ========= Attendance Submission Logic =======================================================================================

  Future<void> preGenerateSemesterAttendance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String resultMessage = await supabase.rpc(
        'generate_semester_attendance',
        params: {
          'p_start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
          'p_end_date': endDate.toIso8601String().split('T')[0],
        },
      );
      debugPrint(resultMessage); // "Successfully pre-generated X attendance records."
    } catch (e) {
      debugPrint('Error generating framework: $e');
    }
  }

  Future<void> submitAttendanceSheet({
    required List<StudentAttendanceLog> logs,
  }) async {
    if (logs.isEmpty) return;

    // 1. Map your UI state objects into raw Postgres modification parameters
    final List<Map<String, dynamic>> rowsToUpdate = logs.map((log) {
      return {
        'attendance_id': log.attendanceId, 
        'enrollment_id': log.enrollmentId,
        'status': log.status, 
      };
    }).toList();

    // 2. Perform a single batch update using upsert
    await supabase
        .from('attendances')
        .upsert(rowsToUpdate);
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