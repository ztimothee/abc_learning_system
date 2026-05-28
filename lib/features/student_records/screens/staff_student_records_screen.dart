import 'package:abc_learning_system/shared/widgets/header_card.dart';
import 'package:flutter/material.dart';

class StaffStudentRecordsScreen extends StatefulWidget {
  const StaffStudentRecordsScreen({super.key});

  @override
  State<StaffStudentRecordsScreen> createState() =>
      _StaffStudentRecordsScreenState();
}

class _StaffStudentRecordsScreenState extends State<StaffStudentRecordsScreen> {
  late final StudentRecordsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StudentRecordsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F8FC), Color(0xFFE9EEF7)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HeaderCard(
                          title: 'Staff Student Records',
                          id: _controller.selectedStudent.studentId,
                          name: _controller.selectedStudent.fullName,
                        ),
                        const SizedBox(height: 16),
                        _SearchBarCard(
                          controller: _controller.searchController,
                          onChanged: _controller.filterStudents,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFD7DFEA)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F0F172A),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 900;
                              final listPane = _StudentListPane(
                                students: _controller.filteredStudents,
                                selectedStudentId:
                                    _controller.selectedStudent.studentId,
                                onSelected: _controller.selectStudent,
                              );
                              final detailsPane = _DetailsPane(
                                detailsVisible: _controller.showDetails,
                                student: _controller.selectedStudent,
                              );

                              if (isWide) {
                                return SizedBox(
                                  height: 520,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: listPane),
                                      const SizedBox(width: 16),
                                      Expanded(child: detailsPane),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 360, child: listPane),
                                  const SizedBox(height: 16),
                                  detailsPane,
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: () {
                            _controller.showDetailsForSelectedStudent();
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('Show Details'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Temporary student records are shown here until backend data is connected.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF5B6475)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class StudentRecordsController extends ChangeNotifier {
  StudentRecordsController() : searchController = TextEditingController() {
    _students = const [
      _StudentRecord(
        studentId: 'STU-1001',
        fullName: 'Alyssa Brown',
        stubCode: 'ENG-201',
        subject: 'English Literature',
        grade: '89',
        remarks: 'Passed',
      ),
      _StudentRecord(
        studentId: 'STU-1002',
        fullName: 'Brian Clark',
        stubCode: 'MATH-202',
        subject: 'Intermediate Algebra',
        grade: '92',
        remarks: 'Passed',
      ),
      _StudentRecord(
        studentId: 'STU-1003',
        fullName: 'Catherine Diaz',
        stubCode: 'SCI-203',
        subject: 'Earth and Life Science',
        grade: '87',
        remarks: 'Passed',
      ),
      _StudentRecord(
        studentId: 'STU-1004',
        fullName: 'Daniel Evans',
        stubCode: 'HIS-204',
        subject: 'World History',
        grade: '90',
        remarks: 'Passed',
      ),
    ];

    _filteredStudents = List.of(_students);
    selectedStudent = _students.first;
  }

  final TextEditingController searchController;
  late final List<_StudentRecord> _students;
  late List<_StudentRecord> _filteredStudents;
  late _StudentRecord selectedStudent;
  bool _showDetails = false;

  List<_StudentRecord> get filteredStudents => _filteredStudents;
  bool get showDetails => _showDetails;

  void filterStudents(String query) {
    final lower = query.toLowerCase();
    _filteredStudents = _students
        .where(
          (student) =>
              student.studentId.toLowerCase().contains(lower) ||
              student.fullName.toLowerCase().contains(lower),
        )
        .toList();

    if (_filteredStudents.isNotEmpty &&
        !_filteredStudents.any(
          (student) => student.studentId == selectedStudent.studentId,
        )) {
      selectedStudent = _filteredStudents.first;
      _showDetails = false;
    }

    notifyListeners();
  }

  void selectStudent(_StudentRecord student) {
    selectedStudent = student;
    _showDetails = false;
    notifyListeners();
  }

  void showDetailsForSelectedStudent() {
    _showDetails = true;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class _StudentRecord {
  const _StudentRecord({
    required this.studentId,
    required this.fullName,
    required this.stubCode,
    required this.subject,
    required this.grade,
    required this.remarks,
  });

  final String studentId;
  final String fullName;
  final String stubCode;
  final String subject;
  final String grade;
  final String remarks;
}

class _SearchBarCard extends StatelessWidget {
  const _SearchBarCard({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7DFEA)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search student by ID or name',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1D4ED8)),
          ),
        ),
      ),
    );
  }
}

class _StudentListPane extends StatelessWidget {
  const _StudentListPane({
    required this.students,
    required this.selectedStudentId,
    required this.onSelected,
  });

  final List<_StudentRecord> students;
  final String selectedStudentId;
  final ValueChanged<_StudentRecord> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Student Name',
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Student ID',
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (context, index) {
              final student = students[index];
              final isSelected = student.studentId == selectedStudentId;

              return InkWell(
                onTap: () => onSelected(student),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          student.fullName,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          student.studentId,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DetailsPane extends StatelessWidget {
  const _DetailsPane({required this.detailsVisible, required this.student});

  final bool detailsVisible;
  final _StudentRecord student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Student Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (!detailsVisible)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Tap "Show Details" to reveal stub code, subject, grades, and remarks.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: [
                _DetailField(label: 'Stub Code', value: student.stubCode),
                const SizedBox(height: 12),
                _DetailField(label: 'Subject', value: student.subject),
                const SizedBox(height: 12),
                _DetailField(label: 'Grades', value: student.grade),
                const SizedBox(height: 12),
                _DetailField(label: 'Remarks', value: student.remarks),
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8E0EA)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
