class CreditDTO {
  final String studentId;
  final double amount;

  CreditDTO({
    required this.studentId,
    required this.amount,
  });

  // Method to convert a CreditDTO instance to a map to submit to the database
  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'amount': amount,
    };
  }
}
