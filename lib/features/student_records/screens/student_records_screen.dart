import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/controllers/theme_settings_controller.dart';
import 'package:abc_learning_system/features/student_records/controllers/student_records_repository.dart';
import 'package:abc_learning_system/features/student_records/models/student_grades_report_dto.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentRecordsScreen extends ConsumerStatefulWidget {
  const StudentRecordsScreen({super.key});

  @override
  ConsumerState<StudentRecordsScreen> createState() =>
      _StudentRecordsScreenState();
}

class _StudentRecordsScreenState extends ConsumerState<StudentRecordsScreen> {
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
    final themeSettings = ref.watch(themeSettingsProvider);
    final theme = Theme.of(context);
    final palette = themeSettings.colorTheme;
    final backgroundStart = theme.brightness == Brightness.dark
        ? Color.lerp(theme.colorScheme.background, palette.dark, 0.18) ??
              theme.colorScheme.background
        : Color.lerp(theme.colorScheme.background, palette.light, 0.08) ??
              theme.colorScheme.background;
    final backgroundEnd = theme.brightness == Brightness.dark
        ? Color.lerp(theme.colorScheme.surface, palette.dark, 0.22) ??
              theme.colorScheme.surface
        : Color.lerp(theme.colorScheme.surface, palette.light, 0.06) ??
              theme.colorScheme.surface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundStart, backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final profileAsync = ref.watch(userProfileProvider);

              return profileAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Error loading profile: $error')),
                data: (profile) {
                  if (profile == null) {
                    return const Center(
                      child: Text(
                        'No student profile is available for this account.',
                      ),
                    );
                  }

                  final userId = profile.userId;
                  if (userId == null || userId.isEmpty) {
                    return const Center(
                      child: Text(
                        'No student ID is available for this account.',
                      ),
                    );
                  }

                  return ref
                      .watch(studentProfileByUserIdProvider(userId))
                      .when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Text('Error loading student profile: $error'),
                        ),
                        data: (studentProfile) {
                          final gradesAsync = ref.watch(
                            fetchStudentGradesProvider(
                              studentProfile.studentId,
                            ),
                          );
                          final fullName = buildFullName(
                            studentProfile.firstName,
                            studentProfile.middleName,
                            studentProfile.lastName,
                          );

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1100,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _HeaderCard(
                                      studentId: studentProfile.displayId,
                                      studentName: fullName,
                                      accentLight: palette.light,
                                      accentDark: palette.dark,
                                    ),
                                    const SizedBox(height: 20),
                                    _GradesTableCard(
                                      gradesAsync: gradesAsync,
                                      visible: _controller.showGrades,
                                      accentColor: palette.dark,
                                    ),
                                    const SizedBox(height: 20),
                                    _SelectionButton(
                                      label: 'School year',
                                      value: _controller.selectedSchoolYear,
                                      icon: Icons.calendar_month_outlined,
                                      accentColor: palette.dark,
                                      onPressed: () => _showSelectionSheet(
                                        context: context,
                                        title: 'Select school year',
                                        options: _controller.schoolYears,
                                        currentValue:
                                            _controller.selectedSchoolYear,
                                        accentColor: palette.dark,
                                        onSelected: _controller.setSchoolYear,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _SelectionButton(
                                      label: 'Semester',
                                      value: _controller.selectedSemester,
                                      icon: Icons.event_note_outlined,
                                      accentColor: palette.dark,
                                      onPressed: () => _showSelectionSheet(
                                        context: context,
                                        title: 'Select semester',
                                        options: _controller.semesters,
                                        currentValue:
                                            _controller.selectedSemester,
                                        accentColor: palette.dark,
                                        onSelected: _controller.setSemester,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    FilledButton(
                                      onPressed: () {
                                        _controller.showGradesNow();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Grades are now loaded from the student records provider.',
                                            ),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size.fromHeight(52),
                                        backgroundColor: palette.dark,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Show My Grades'),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Grade data is pulled from the signed-in student record and the app theme follows the selected palette.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                },
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
    required Color accentColor,
    required ValueChanged<String> onSelected,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;

    final selectedValue = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        side: BorderSide(
                          color: option == currentValue
                              ? accentColor
                              : Theme.of(context).colorScheme.outline,
                        ),
                        backgroundColor: option == currentValue
                            ? Color.lerp(
                                Theme.of(context).colorScheme.surface,
                                accentColor,
                                0.12,
                              )
                            : Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(option)),
                          if (option == currentValue)
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: accentColor,
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
    : selectedSchoolYear = '2025-2026',
      selectedSemester = '1st Semester',
      _showGrades = false;

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
  const _HeaderCard({
    required this.studentId,
    required this.studentName,
    required this.accentLight,
    required this.accentDark,
  });

  final String studentId;
  final String studentName;
  final Color accentLight;
  final Color accentDark;

  @override
  Widget build(BuildContext context) {
    final colors = [darken(accentLight, 0.22), darken(accentDark, 0.1)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
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
  const _GradesTableCard({
    required this.gradesAsync,
    required this.visible,
    required this.accentColor,
  });

  final AsyncValue<List<StudentGradesReportDTO>> gradesAsync;
  final bool visible;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        ////////// border: Border.all(color: _recordsPanelBorderColor),
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
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Student Grades',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Grades are loaded from the signed-in student record.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (!visible)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 34,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap "Show My Grades" to display the student records data.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            gradesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Text(
                  'Unable to load grades: $error',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (grades) {
                if (grades.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Text(
                      'No grade records were returned for this student.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 28,
                      horizontalMargin: 16,
                      headingRowColor: WidgetStateProperty.all(
                        Color.lerp(
                              theme.colorScheme.surface,
                              accentColor,
                              0.12,
                            ) ??
                            theme.colorScheme.surface,
                      ),
                      columns: const [
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('Stub Code')),
                        DataColumn(label: Text('Final Grade')),
                        DataColumn(label: Text('Remarks')),
                      ],
                      rows: grades
                          .map(
                            (grade) => DataRow(
                              cells: [
                                DataCell(Text(grade.subjectName)),
                                DataCell(Text(grade.stubCode)),
                                DataCell(
                                  Text(grade.finalGrade?.toString() ?? 'N/A'),
                                ),
                                DataCell(Text(grade.remarks)),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
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
    required this.accentColor,
    required this.onPressed,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        alignment: Alignment.centerLeft,
        foregroundColor: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: accentColor.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.expand_more, color: theme.colorScheme.outline),
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
