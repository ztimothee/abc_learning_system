class Subject {
  final String subjectId;
  final String subjectName;
  final double tuitionFee;

  Subject({
    required this.subjectId,
    required this.subjectName,
    required this.tuitionFee,
  });

  // Factory constructor to create a Subject instance from a map retrieved from the database
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      subjectId: map['subject_id'],
      subjectName: map['subject_name'],
      tuitionFee: map['tuition_fee'].toDouble(),
    );
  }

  // Method to convert a Subject instance to a map to submit to the database
  Map<String, dynamic> toMap() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'tuition_fee': tuitionFee,
    };
  }
}
