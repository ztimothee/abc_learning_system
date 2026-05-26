class SubjectDTO {
  final String subjectId;
  final String subjectName;
  final double tuitionFee;

  SubjectDTO({
    required this.subjectId,
    required this.subjectName,
    required this.tuitionFee,
  });

  factory SubjectDTO.fromMap(Map<String, dynamic> map) {
    return SubjectDTO(
      subjectId: map['subject_id'] ?? '',
      subjectName: map['subject_name'] ?? '',
      tuitionFee: double.tryParse(map['tuition_fee']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class BatchedSubjectsDTO {
  final String batchId;
  final String batchName;
  final DateTime createdAt;
  final List<SubjectDTO> subjects;

  BatchedSubjectsDTO({
    required this.batchId,
    required this.batchName,
    required this.createdAt,
    required this.subjects,
  });

  factory BatchedSubjectsDTO.fromMap(Map<String, dynamic> map) {
    final bridgeList = map['subject_to_batch'] as List<dynamic>? ?? [];

    final subjects = bridgeList.map((bridgeItem) {
      if (bridgeItem is Map<String, dynamic> && bridgeItem['subjects'] != null) {
        return SubjectDTO.fromMap(bridgeItem['subjects'] as Map<String, dynamic>);
      }
      return null; // Skip if the structure is not as expected
    }).whereType<SubjectDTO>().toList();

    return BatchedSubjectsDTO(
      batchId: map['batch_id'] ?? '',
      batchName: map['batch_name'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      subjects: subjects,
    );
  }
}
