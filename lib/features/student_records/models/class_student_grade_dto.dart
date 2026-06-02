class ClassStudentGradeDTO {
  final String? gradeId; // Add this field
  final String enrollmentId;
  final String studentDisplayId; 
  final String studentName;      
  final int? finalGrade;         
  final String remarks;

  ClassStudentGradeDTO({
    this.gradeId, // Make it optional
    required this.enrollmentId,
    required this.studentDisplayId,
    required this.studentName,
    this.finalGrade,
    required this.remarks,
  });

  factory ClassStudentGradeDTO.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> gradeData = {};
    final rawGrades = map['grades'];
    if (rawGrades is List && rawGrades.isNotEmpty) {
      gradeData = rawGrades.first;
    } else if (rawGrades is Map<String, dynamic>) {
      gradeData = rawGrades;
    }

    return ClassStudentGradeDTO(
      gradeId: gradeData['grade_id']?.toString(), // Pull the grade_id out
      enrollmentId: map['enrollment_id']?.toString() ?? '',
      studentDisplayId: map['display_id']?.toString() ?? 'N/A',
      studentName: map['last_name'] != null 
          ? '${map['last_name']}, ${map['first_name']}'
          : 'Unknown Student',
      finalGrade: gradeData['final_grade'] != null 
          ? int.tryParse(gradeData['final_grade'].toString()) 
          : null,
      remarks: gradeData['remarks']?.toString() ?? '',
    );
  }
}