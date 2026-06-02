class LedgerEntryDTO {
  final DateTime date;
  final String semester;
  final String particulars;
  final double debit;
  final double credit;
  final double balance;

  LedgerEntryDTO({
    required this.date,
    required this.semester,
    required this.particulars,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory LedgerEntryDTO.fromMap(Map<String, dynamic> map) {
    return LedgerEntryDTO(
      date: DateTime.parse(map['date']),
      semester: map['sem'] ?? '',
      particulars: map['particulars'] ?? '',
      debit: (map['debit'] as num).toDouble(),
      credit: (map['credit'] as num).toDouble(),
      balance: (map['balance'] as num).toDouble(),
    );
  }
}
