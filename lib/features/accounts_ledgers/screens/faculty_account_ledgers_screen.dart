import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FacultyAccountLedgersScreen extends ConsumerStatefulWidget {
  const FacultyAccountLedgersScreen({super.key});

  @override
  ConsumerState<FacultyAccountLedgersScreen> createState() =>
      _FacultyAccountLedgersScreenState();
}

class _FacultyAccountLedgersScreenState
    extends ConsumerState<FacultyAccountLedgersScreen> {
  late final _AccountsLedgerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _AccountsLedgerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts Ledger'), centerTitle: false),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FC), Color(0xFFE7EEF8)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StudentSummaryHeader(
                      studentId: _controller.selectedStudent.studentId,
                      studentName: _controller.selectedStudent.studentName,
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFD8E0EA)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F0F172A),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 960;
                            final leftPane = _StudentPane(
                              searchController: _controller.searchController,
                              students: _controller.filteredStudents,
                              selectedStudentId:
                                  _controller.selectedStudent.studentId,
                              onStudentSelected: _controller.selectStudent,
                              onSearchChanged: _controller.filterStudents,
                            );
                            final rightPane = _LedgerPane(
                              entries: _controller.entriesForSelectedStudent,
                              onAddPressed: () async {
                                final result = await Navigator.of(context)
                                    .push<_LedgerEntry>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const _AddLedgerEntryPage(),
                                      ),
                                    );
                                if (result != null) {
                                  _controller.addEntry(result);
                                }
                              },
                            );

                            if (isWide) {
                              return Row(
                                children: [
                                  Expanded(child: leftPane),
                                  const VerticalDivider(width: 1, thickness: 1),
                                  Expanded(flex: 2, child: rightPane),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Expanded(child: leftPane),
                                const Divider(height: 1, thickness: 1),
                                Expanded(flex: 2, child: rightPane),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AccountsLedgerController extends ChangeNotifier {
  _AccountsLedgerController() : searchController = TextEditingController() {
    _students = const [
      _Student(studentId: 'STU-1001', studentName: 'Alyssa Brown'),
      _Student(studentId: 'STU-1002', studentName: 'Brian Clark'),
      _Student(studentId: 'STU-1003', studentName: 'Catherine Diaz'),
      _Student(studentId: 'STU-1004', studentName: 'Daniel Evans'),
    ];
    _ledgerByStudentId = {
      'STU-1001': [
        _LedgerEntry(
          date: '2026-05-01',
          semester: '1st Sem',
          particulars: 'Tuition Fee',
          debit: 1500,
          credit: 0,
          balance: 1500,
        ),
        _LedgerEntry(
          date: '2026-05-10',
          semester: '1st Sem',
          particulars: 'Partial Payment',
          debit: 0,
          credit: 500,
          balance: 1000,
        ),
      ],
      'STU-1002': [
        _LedgerEntry(
          date: '2026-05-02',
          semester: '1st Sem',
          particulars: 'Registration',
          debit: 300,
          credit: 0,
          balance: 300,
        ),
      ],
      'STU-1003': [
        _LedgerEntry(
          date: '2026-05-03',
          semester: '2nd Sem',
          particulars: 'Lab Fee',
          debit: 450,
          credit: 0,
          balance: 450,
        ),
      ],
      'STU-1004': [
        _LedgerEntry(
          date: '2026-05-04',
          semester: '2nd Sem',
          particulars: 'Miscellaneous',
          debit: 250,
          credit: 0,
          balance: 250,
        ),
      ],
    };
    _filteredStudents = List.of(_students);
    selectedStudent = _students.first;
  }

  final TextEditingController searchController;
  late final List<_Student> _students;
  late final Map<String, List<_LedgerEntry>> _ledgerByStudentId;
  late List<_Student> _filteredStudents;
  late _Student selectedStudent;

  List<_Student> get filteredStudents => _filteredStudents;

  List<_LedgerEntry> get entriesForSelectedStudent =>
      _ledgerByStudentId[selectedStudent.studentId] ?? const [];

  void filterStudents(String query) {
    final lower = query.toLowerCase();
    _filteredStudents = _students
        .where(
          (student) =>
              student.studentId.toLowerCase().contains(lower) ||
              student.studentName.toLowerCase().contains(lower),
        )
        .toList();
    if (!_filteredStudents.any(
          (student) => student.studentId == selectedStudent.studentId,
        ) &&
        _filteredStudents.isNotEmpty) {
      selectedStudent = _filteredStudents.first;
    }
    notifyListeners();
  }

  void selectStudent(_Student student) {
    selectedStudent = student;
    notifyListeners();
  }

  void addEntry(_LedgerEntry entry) {
    final currentEntries = List<_LedgerEntry>.from(
      _ledgerByStudentId[selectedStudent.studentId] ?? const [],
    );
    final previousBalance = currentEntries.isEmpty
        ? 0.0
        : currentEntries.last.balance;
    final updatedEntry = entry.copyWith(
      balance: previousBalance + entry.debit - entry.credit,
    );
    _ledgerByStudentId[selectedStudent.studentId] = [
      ...currentEntries,
      updatedEntry,
    ];
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class _Student {
  const _Student({required this.studentId, required this.studentName});

  final String studentId;
  final String studentName;
}

class _LedgerEntry {
  const _LedgerEntry({
    required this.date,
    required this.semester,
    required this.particulars,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  final String date;
  final String semester;
  final String particulars;
  final double debit;
  final double credit;
  final double balance;

  _LedgerEntry copyWith({double? balance}) {
    return _LedgerEntry(
      date: date,
      semester: semester,
      particulars: particulars,
      debit: debit,
      credit: credit,
      balance: balance ?? this.balance,
    );
  }
}

class _StudentSummaryHeader extends StatelessWidget {
  const _StudentSummaryHeader({
    required this.studentId,
    required this.studentName,
  });

  final String studentId;
  final String studentName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8E0EA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeaderStat(label: 'Student ID Number', value: studentId),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HeaderStat(label: 'Student Name', value: studentName),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _StudentPane extends StatelessWidget {
  const _StudentPane({
    required this.searchController,
    required this.students,
    required this.selectedStudentId,
    required this.onStudentSelected,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final List<_Student> students;
  final String selectedStudentId;
  final ValueChanged<_Student> onStudentSelected;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search student',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final student = students[index];
                final isSelected = student.studentId == selectedStudentId;
                return InkWell(
                  onTap: () => onStudentSelected(student),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFD8E0EA),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF2563EB),
                          child: Text(student.studentName.characters.first),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.studentName,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student.studentId,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_off,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerPane extends StatelessWidget {
  const _LedgerPane({required this.entries, required this.onAddPressed});

  final List<_LedgerEntry> entries;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Sem',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Particulars',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Expanded(
                child: Text(
                  'Deb',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cred',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Balance',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'No ledger entries yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Row(
                        children: [
                          Expanded(flex: 2, child: Text(entry.date)),
                          Expanded(flex: 2, child: Text(entry.semester)),
                          Expanded(flex: 4, child: Text(entry.particulars)),
                          Expanded(
                            child: Text(
                              entry.debit.toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.credit.toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.balance.toStringAsFixed(2),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddLedgerEntryPage extends StatefulWidget {
  const _AddLedgerEntryPage();

  @override
  State<_AddLedgerEntryPage> createState() => _AddLedgerEntryPageState();
}

class _AddLedgerEntryPageState extends State<_AddLedgerEntryPage> {
  late final TextEditingController _particularsController;
  late final TextEditingController _debitController;
  late final TextEditingController _creditController;

  @override
  void initState() {
    super.initState();
    _particularsController = TextEditingController(text: 'New charge');
    _debitController = TextEditingController(text: '0');
    _creditController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _particularsController.dispose();
    _debitController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Ledger Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _particularsController,
              decoration: const InputDecoration(labelText: 'Particulars'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _debitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Debit'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _creditController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Credit'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                final debit = double.tryParse(_debitController.text) ?? 0;
                final credit = double.tryParse(_creditController.text) ?? 0;
                Navigator.of(context).pop(
                  _LedgerEntry(
                    date: DateTime.now().toIso8601String().split('T').first,
                    semester: '1st Sem',
                    particulars: _particularsController.text,
                    debit: debit,
                    credit: credit,
                    balance: 0,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
