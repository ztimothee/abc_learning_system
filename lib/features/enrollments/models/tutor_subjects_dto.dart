class TutorSubjectsDTO {
  final String subjectAssignedId;
  final String stubCode;
  final String subjectName;

  TutorSubjectsDTO({
    required this.subjectAssignedId,
    required this.stubCode,
    required this.subjectName,
  });

  factory TutorSubjectsDTO.fromMap(Map<String, dynamic> map) {
    final subjectData = map['subjects'] as Map<String, dynamic>? ?? {};

    return TutorSubjectsDTO(
      subjectAssignedId: map['subject_assigned_id'] ?? '',
      stubCode: map['stub_code'] ?? 'No Stub Code',
      subjectName: subjectData['subject_name'] as String? ?? 'Unknown Subject'
    );
  }
}
