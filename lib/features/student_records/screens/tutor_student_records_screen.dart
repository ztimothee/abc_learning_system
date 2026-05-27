import 'package:flutter/material.dart';

class TutorStudentRecordsScreen extends StatefulWidget {
  const TutorStudentRecordsScreen({super.key});

  @override
  State<TutorStudentRecordsScreen> createState() =>
      _TutorStudentRecordsScreenState();
}

class _TutorStudentRecordsScreenState extends State<TutorStudentRecordsScreen> {
  late final TutorStudentRecordsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TutorStudentRecordsController();
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
            colors: [Color(0xFFF7F9FC), Color(0xFFE6EDF7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TeacherHeaderCard(
                      teacherId: _controller.teacherId,
                      teacherName: _controller.teacherName,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 960;
                              final firstColumn = _BorderedPanel(
                                title: 'Subject List',
                                subtitle:
                                    'Select an assigned subject and its stub code.',
                                child: _SelectableSubjectList(
                                  subjects: _controller.subjects,
                                  selectedSubjectCode:
                                      _controller.selectedSubject.subjectCode,
                                  onSelected: _controller.selectSubject,
                                ),
                              );
                              final secondColumn = _BorderedPanel(
                                title: 'Student Lists',
                                subtitle:
                                    'Choose a student that belongs to the selected subject.',
                                child: _SelectableStudentList(
                                  students: _controller.filteredStudents,
                                  selectedStudentId:
                                      _controller.selectedStudent?.studentId,
                                  onSelected: _controller.selectStudent,
                                ),
                              );
                              final thirdColumn = _BorderedPanel(
                                title: 'Selected Details',
                                subtitle:
                                    'Review the selected subject and student, then enter a grade.',
                                child: _SelectedGradeForm(
                                  subjectCodeController:
                                      _controller.subjectCodeController,
                                  subjectNameController:
                                      _controller.subjectNameController,
                                  studentIdController:
                                      _controller.studentIdController,
                                  studentNameController:
                                      _controller.studentNameController,
                                  gradeController: _controller.gradeController,
                                  onGradeNow: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Grade saved temporarily for ${_controller.selectedStudent?.studentName ?? 'the selected student'}.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );

                              if (isWide) {
                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: firstColumn),
                                    const SizedBox(width: 16),
                                    Expanded(child: secondColumn),
                                    const SizedBox(width: 16),
                                    Expanded(child: thirdColumn),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: firstColumn),
                                  const SizedBox(height: 16),
                                  Expanded(child: secondColumn),
                                  const SizedBox(height: 16),
                                  Expanded(child: thirdColumn),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Temporary placeholder data is shown here until backend integration is ready.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TutorStudentRecordsController extends ChangeNotifier {
  TutorStudentRecordsController()
    : teacherId = 'TCH-2026-014',
      teacherName = 'Mrs. Olivia Carter',
      gradeController = TextEditingController(text: '90') {
    selectedSubject = subjects.first;
    selectedStudent = filteredStudents.firstOrNull;
    _syncSelectedControllers();
  }

  final String teacherId;
  final String teacherName;
  final TextEditingController subjectCodeController = TextEditingController();
  final TextEditingController subjectNameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController gradeController;

  final List<_TutorSubject> subjects = const [
    _TutorSubject(subjectCode: 'ENG-201', subjectName: 'English Literature'),
    _TutorSubject(subjectCode: 'MATH-202', subjectName: 'Intermediate Algebra'),
    _TutorSubject(
      subjectCode: 'SCI-203',
      subjectName: 'Earth and Life Science',
    ),
  ];

  final List<_TutorStudent> _students = const [
    _TutorStudent(
      subjectCode: 'ENG-201',
      studentId: 'STU-1001',
      studentName: 'Alyssa Brown',
    ),
    _TutorStudent(
      subjectCode: 'ENG-201',
      studentId: 'STU-1002',
      studentName: 'Brian Clark',
    ),
    _TutorStudent(
      subjectCode: 'MATH-202',
      studentId: 'STU-2001',
      studentName: 'Catherine Diaz',
    ),
    _TutorStudent(
      subjectCode: 'MATH-202',
      studentId: 'STU-2002',
      studentName: 'Daniel Evans',
    ),
    _TutorStudent(
      subjectCode: 'SCI-203',
      studentId: 'STU-3001',
      studentName: 'Elena Foster',
    ),
    _TutorStudent(
      subjectCode: 'SCI-203',
      studentId: 'STU-3002',
      studentName: 'Farah Gomez',
    ),
  ];

  late _TutorSubject selectedSubject;
  _TutorStudent? selectedStudent;

  List<_TutorStudent> get filteredStudents => _students
      .where((student) => student.subjectCode == selectedSubject.subjectCode)
      .toList();

  void selectSubject(_TutorSubject subject) {
    selectedSubject = subject;
    final nextStudent = filteredStudents.firstOrNull;
    selectedStudent = nextStudent;
    gradeController.text = '90';
    _syncSelectedControllers();
    notifyListeners();
  }

  void selectStudent(_TutorStudent student) {
    selectedStudent = student;
    _syncSelectedControllers();
    notifyListeners();
  }

  void _syncSelectedControllers() {
    subjectCodeController.text = selectedSubject.subjectCode;
    subjectNameController.text = selectedSubject.subjectName;
    studentIdController.text =
        selectedStudent?.studentId ?? 'No student selected';
    studentNameController.text =
        selectedStudent?.studentName ?? 'No student selected';
  }

  @override
  void dispose() {
    subjectCodeController.dispose();
    subjectNameController.dispose();
    studentIdController.dispose();
    studentNameController.dispose();
    gradeController.dispose();
    super.dispose();
  }
}

class _TeacherHeaderCard extends StatelessWidget {
  const _TeacherHeaderCard({
    required this.teacherId,
    required this.teacherName,
  });

  final String teacherId;
  final String teacherName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF2563EB)],
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
              Icons.person_outline,
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
                  'Tutor Student Records',
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
                    _InfoChip(label: 'Teacher ID', value: teacherId),
                    _InfoChip(label: 'Teacher Name', value: teacherName),
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

class _BorderedPanel extends StatelessWidget {
  const _BorderedPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7DFEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SelectableSubjectList extends StatelessWidget {
  const _SelectableSubjectList({
    required this.subjects,
    required this.selectedSubjectCode,
    required this.onSelected,
  });

  final List<_TutorSubject> subjects;
  final String? selectedSubjectCode;
  final ValueChanged<_TutorSubject> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: subjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final selected = subject.subjectCode == selectedSubjectCode;
        return InkWell(
          onTap: () => onSelected(subject),
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFD8E0EA),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    subject.subjectCode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.subjectName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stub Code: ${subject.subjectCode}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectableStudentList extends StatelessWidget {
  const _SelectableStudentList({
    required this.students,
    required this.selectedStudentId,
    required this.onSelected,
  });

  final List<_TutorStudent> students;
  final String? selectedStudentId;
  final ValueChanged<_TutorStudent> onSelected;

  @override
  Widget build(BuildContext context) {
    return students.isEmpty
        ? Center(
            child: Text(
              'No students available for this subject.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          )
        : ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final student = students[index];
              final selected = student.studentId == selectedStudentId;
              return InkWell(
                onTap: () => onSelected(student),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFD8E0EA),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: selected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFCBD5E1),
                        child: Text(
                          student.studentName.characters.first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
                              'Student ID: ${student.studentId}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected ? Icons.check_circle : Icons.radio_button_off,
                        color: selected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class _SelectedGradeForm extends StatelessWidget {
  const _SelectedGradeForm({
    required this.subjectCodeController,
    required this.subjectNameController,
    required this.studentIdController,
    required this.studentNameController,
    required this.gradeController,
    required this.onGradeNow,
  });

  final TextEditingController subjectCodeController;
  final TextEditingController subjectNameController;
  final TextEditingController studentIdController;
  final TextEditingController studentNameController;
  final TextEditingController gradeController;
  final VoidCallback onGradeNow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ViewOnlyField(
                label: 'Subject Stub Code',
                controller: subjectCodeController,
              ),
              const SizedBox(height: 12),
              _ViewOnlyField(
                label: 'Subject Name',
                controller: subjectNameController,
              ),
              const SizedBox(height: 12),
              _ViewOnlyField(
                label: 'Student ID',
                controller: studentIdController,
              ),
              const SizedBox(height: 12),
              _ViewOnlyField(
                label: 'Student Name',
                controller: studentNameController,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gradeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Grade',
                  hintText: 'Enter grade',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFD8E0EA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFD8E0EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2563EB)),
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onGradeNow,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Grade Now'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewOnlyField extends StatelessWidget {
  const _ViewOnlyField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD8E0EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD8E0EA)),
        ),
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

class _TutorSubject {
  const _TutorSubject({required this.subjectCode, required this.subjectName});

  final String subjectCode;
  final String subjectName;
}

class _TutorStudent {
  const _TutorStudent({
    required this.subjectCode,
    required this.studentId,
    required this.studentName,
  });

  final String subjectCode;
  final String studentId;
  final String studentName;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
