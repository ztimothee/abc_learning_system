import 'package:abc_learning_system/features/enrollments/models/subject_assignment_dto.dart';
import 'package:flutter/material.dart';

class ScheduledSubjectDTO {
  final String scheduleId;
  final int weekday;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final SubjectAssignmentDTO? subjectAssignment;

  ScheduledSubjectDTO({
    required this.scheduleId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.subjectAssignment,
  });

  // Factory constructor to create a ScheduledSubjectDTO from a map (e.g., from Supabase)
  factory ScheduledSubjectDTO.fromMap(Map<String, dynamic> map) {
    final subjectAssignmentsList = map['subject_assignments'] as List<dynamic>? ?? [];

    final finalList = subjectAssignmentsList.map((item) {
      if (item is Map<String, dynamic> && item['subjects'] != null && item['tutors'] != null) {
        return SubjectAssignmentDTO.fromMap(item);
      } 
      return null; // Return null for items that don't match the expected structure
    }).whereType<SubjectAssignmentDTO>().toList();

    return ScheduledSubjectDTO(
      scheduleId: map['schedule_id'] as String,
      weekday: map['weekday'] as int,
      startTime: TimeOfDay(
        hour: (map['start_time'] as String).split(':')[0] as int,
        minute: (map['start_time'] as String).split(':')[1] as int,
      ),
      endTime: TimeOfDay(
        hour: (map['end_time'] as String).split(':')[0] as int,
        minute: (map['end_time'] as String).split(':')[1] as int,
      ),
      subjectAssignment: finalList.isNotEmpty ? finalList.first : null,
    );
  }
}
