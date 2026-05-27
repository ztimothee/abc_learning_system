import 'package:flutter/material.dart';

class StudentRecordsScreen extends StatefulWidget {
  const StudentRecordsScreen({super.key});

  @override
  State<StudentRecordsScreen> createState() => _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends State<StudentRecordsScreen> {
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderCard(
                          studentId: _controller.studentId,
                          studentName: _controller.studentName,
                        ),
                        const SizedBox(height: 20),
                        _GradesTableCard(
                          grades: _controller.grades,
                          visible: _controller.showGrades,
                        ),
                        const SizedBox(height: 20),
                        _SelectionButton(
                          label: 'School year',
                          value: _controller.selectedSchoolYear,
                          icon: Icons.calendar_month_outlined,
                          onPressed: () => _showSelectionSheet(
                            context: context,
                            title: 'Select school year',
                            options: _controller.schoolYears,
                            currentValue: _controller.selectedSchoolYear,
                            onSelected: _controller.setSchoolYear,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SelectionButton(
                          label: 'Semester',
                          value: _controller.selectedSemester,
                          icon: Icons.event_note_outlined,
                          onPressed: () => _showSelectionSheet(
                            context: context,
                            title: 'Select semester',
                            options: _controller.semesters,
                            currentValue: _controller.selectedSemester,
                            onSelected: _controller.setSemester,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            _controller.showGradesNow();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Temporary grades displayed.'),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('Show My Grades'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selections are temporary placeholders until backend data is connected.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF5B6475)),
                          textAlign: TextAlign.center,
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

  Future<void> _showSelectionSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) async {
    final selectedValue = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(option),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        alignment: Alignment.centerLeft,
                        foregroundColor: const Color(0xFF0F172A),
                        side: BorderSide(
                          color: option == currentValue
                              ? const Color(0xFF1D4ED8)
                              : const Color(0xFFCBD5E1),
                        ),
                        backgroundColor: option == currentValue
                            ? const Color(0xFFEFF6FF)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(option)),
                          if (option == currentValue)
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Color(0xFF1D4ED8),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedValue != null) {
      onSelected(selectedValue);
    }
  }
}

class StudentRecordsController extends ChangeNotifier {
  StudentRecordsController()
    : studentId = 'STU-2026-001',
      studentName = 'John Doe',
      selectedSchoolYear = '2025-2026',
      selectedSemester = '1st Semester',
      _showGrades = false;

  final String studentId;
  final String studentName;
  final List<String> schoolYears = const [
    '2024-2025',
    '2025-2026',
    '2026-2027',
  ];
  final List<String> semesters = const [
    '1st Semester',
    '2nd Semester',
    'Summer Term',
  ];
  final List<_GradeRowData> grades = const [
    _GradeRowData(
      subjectCode: 'MATH-101',
      subjectName: 'Basic Mathematics',
      studentGrade: '89',
      remarks: 'Passed',
    ),
    _GradeRowData(
      subjectCode: 'ENG-102',
      subjectName: 'Communication Arts',
      studentGrade: '92',
      remarks: 'Passed',
    ),
    _GradeRowData(
      subjectCode: 'SCI-103',
      subjectName: 'General Science',
      studentGrade: '87',
      remarks: 'Passed',
    ),
  ];

  String selectedSchoolYear;
  String selectedSemester;
  bool _showGrades;

  bool get showGrades => _showGrades;

  void setSchoolYear(String value) {
    selectedSchoolYear = value;
    notifyListeners();
  }

  void setSemester(String value) {
    selectedSemester = value;
    notifyListeners();
  }

  void showGradesNow() {
    _showGrades = true;
    notifyListeners();
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.studentId, required this.studentName});

  final String studentId;
  final String studentName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Record',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 18,
                  runSpacing: 12,
                  children: [
                    _InfoChip(label: 'Student ID', value: studentId),
                    _InfoChip(label: 'Student Name', value: studentName),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradesTableCard extends StatelessWidget {
  const _GradesTableCard({required this.grades, required this.visible});

  final List<_GradeRowData> grades;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Temporary Grades',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'A preview of placeholder grade data for the selected term.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          if (!visible)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    size: 34,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap "Show My Grades" to display the temporary data.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475569),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 28,
                  horizontalMargin: 16,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFEFF6FF),
                  ),
                  columns: const [
                    DataColumn(label: Text('Subject Code')),
                    DataColumn(label: Text('Subject Name')),
                    DataColumn(label: Text('Student Grade')),
                    DataColumn(label: Text('Remarks')),
                  ],
                  rows: grades
                      .map(
                        (grade) => DataRow(
                          cells: [
                            DataCell(Text(grade.subjectCode)),
                            DataCell(Text(grade.subjectName)),
                            DataCell(Text(grade.studentGrade)),
                            DataCell(Text(grade.remarks)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectionButton extends StatelessWidget {
  const _SelectionButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        alignment: Alignment.centerLeft,
        foregroundColor: const Color(0xFF0F172A),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1D4ED8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Icon(Icons.expand_more, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeRowData {
  const _GradeRowData({
    required this.subjectCode,
    required this.subjectName,
    required this.studentGrade,
    required this.remarks,
  });

  final String subjectCode;
  final String subjectName;
  final String studentGrade;
  final String remarks;
}
