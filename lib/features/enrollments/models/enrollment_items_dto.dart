class EnrollmentItemsDTO {
  final String enrollmentId;
  final String subjectName;
  final double tuitionFee;
  final String stubCode;
  final String formattedSchedule;
  final int enrollmentStatus;

  EnrollmentItemsDTO({
    required this.enrollmentId,
    required this.subjectName,
    required this.tuitionFee,
    required this.stubCode,
    required this.formattedSchedule,
    required this.enrollmentStatus,
  });

  factory EnrollmentItemsDTO.fromMap(Map<String, dynamic> map) {
    return EnrollmentItemsDTO(
      enrollmentId: map['enrollment_id'] ?? '',
      subjectName: map['subject_name'] ?? 'Unknown Subject',
      tuitionFee: double.tryParse(map['tuition_fee']?.toString() ?? '0') ?? 0.0,
      stubCode: map['stub_code'] ?? 'N/A',
      formattedSchedule: map['formatted_schedule'] ?? 'No Schedule',
      enrollmentStatus: map['enrollment_status'] ?? 0,
    );
  }
}

class StudentEnrollmentSummaryDTO {
  final List<EnrollmentItemsDTO> enrollments;
  final double totalTuition;

  StudentEnrollmentSummaryDTO({
    required this.enrollments,
    required this.totalTuition,
  });
}
