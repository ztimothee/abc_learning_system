class GradesDTO {
  final String enrollmentId;
  final int finalGrade;
  final String remarks;

  GradesDTO({
    required this.enrollmentId,
    required this.finalGrade,
    required this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'enrollment_id': enrollmentId,
      'final_grade': finalGrade,
      'remarks': remarks,
    };
  }
}