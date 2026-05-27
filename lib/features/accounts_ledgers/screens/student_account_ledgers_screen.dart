import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentAccountLedgersScreen extends ConsumerStatefulWidget {
  const StudentAccountLedgersScreen({super.key});

  @override
  ConsumerState<StudentAccountLedgersScreen> createState() =>
      _StudentAccountLedgersScreenState();
}

class _StudentAccountLedgersScreenState
    extends ConsumerState<StudentAccountLedgersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Accounts Ledger'),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FC), Color(0xFFE7EEF8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StudentHeader(
                      studentId: 'STU-1001',
                      studentName: 'Alyssa Brown',
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD8E0EA)),
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
                          children: const [
                            _LedgerTableSection(
                              subjectName: 'English Literature',
                              tutorName: 'Mrs. Olivia Carter',
                              schedule: 'Mon / Wed / Fri - 9:00 AM to 10:30 AM',
                              price: 'PHP 1,500.00',
                            ),
                            SizedBox(height: 16),
                            Divider(height: 32),
                            _TotalSection(total: 'PHP 1,500.00'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.studentId, required this.studentName});

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
            child: _HeaderField(label: 'Student ID Number', value: studentId),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HeaderField(label: 'Student Name', value: studentName),
          ),
        ],
      ),
    );
  }
}

class _HeaderField extends StatelessWidget {
  const _HeaderField({required this.label, required this.value});

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

class _LedgerTableSection extends StatelessWidget {
  const _LedgerTableSection({
    required this.subjectName,
    required this.tutorName,
    required this.schedule,
    required this.price,
  });

  final String subjectName;
  final String tutorName;
  final String schedule;
  final String price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Subject Name',
                  style: theme.textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Tutor Name',
                  style: theme.textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Schedule',
                  style: theme.textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Price',
                  style: theme.textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 1,
          separatorBuilder: (_, __) => const Divider(height: 12),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(subjectName, textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(tutorName, textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(schedule, textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      price,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TotalSection extends StatelessWidget {
  const _TotalSection({required this.total});

  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Text(
            'Total',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Text(
            total,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }
}
