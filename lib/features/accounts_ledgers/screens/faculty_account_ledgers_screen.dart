import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/features/accounts_ledgers/controllers/accounts_ledgers_repository.dart';
import 'package:abc_learning_system/features/accounts_ledgers/models/ledger_entry_dto.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:abc_learning_system/shared/widgets/bordered_surface.dart';
import 'package:abc_learning_system/shared/widgets/bulleted_instructions_card.dart';
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
  final TextEditingController _displayIdController = TextEditingController();
  String _searchedDisplayId = '';
  final Set<String> _stagedBatchIds = <String>{};

  @override
  void dispose() {
    _displayIdController.dispose();
    super.dispose();
  }

  void _searchStudent() {
    final displayId = _displayIdController.text.trim();
    setState(() {
      _searchedDisplayId = displayId;
      _stagedBatchIds.clear();
    });
  }

  Future<void> _showLogPaymentDialog({
    required String studentId,
    required String studentDisplayId,
  }) async {
    // 💡 FIX: Dialog inputs are now safely managed inside their own lifecycle class
    final values = await showDialog<_PaymentFormValues>(
      context: context,
      builder: (dialogContext) => _PaymentDialog(
        studentDisplayId: studentDisplayId,
        studentId: studentId,
      ),
    );

    if (values == null || !mounted) return;

    await ref
        .read(accountsLedgersOperationControllerProvider.notifier)
        .logPayment(
          studentId: values.studentId,
          semester: values.semester,
          paymentAmount: values.paymentAmount,
          paymentMethod: values.paymentMethod,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student payment logged successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmedDisplayId = _searchedDisplayId.trim();

    // 💡 FIX 1: Watch the profile provider cleanly at the top level
    final studentProfileAsync = trimmedDisplayId.isEmpty
        ? null
        : ref.watch(studentProfileByDisplayIdProvider(trimmedDisplayId));

    // 💡 FIX 2: Safely extract the student internal ID using valueOrNull
    final currentStudentId = studentProfileAsync?.value?.studentId;

    // 💡 FIX 3: Watch the ledger statement at the top level unconditionally
    final ledgerAsync = currentStudentId == null
        ? const AsyncValue<List<LedgerEntryDTO>>.data([])
        : ref.watch(studentLedgerStatementProvider(currentStudentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Account Ledgers')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BulletedInstructionsCard(
              title: 'Faculty account ledgers flow',
              instructions: const [
                'Search a faculty member using the display ID to load their account ledgers.',
                'Tap a batch to stage all of its subjects for the selected faculty member.',
                'Use Add Subjects to assign the staged subjects to the faculty member.',
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _displayIdController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchStudent(),
              decoration: InputDecoration(
                labelText: 'Student Display ID',
                hintText: 'Enter display ID and press Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search student',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _searchStudent,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (trimmedDisplayId.isNotEmpty && studentProfileAsync != null)
              studentProfileAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: BorderedSurface(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Loading student details...'),
                        ],
                      ),
                    ),
                  ),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: BorderedSurface(
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Student search error: $error',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                data: (studentProfile) {
                  final fullName = [
                    studentProfile.firstName,
                    studentProfile.middleName ?? '',
                    studentProfile.lastName,
                  ].where((part) => part.trim().isNotEmpty).join(' ');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: BorderedSurface(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Student Name',
                                        style: theme.textTheme.labelMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        fullName.isEmpty
                                            ? 'Unnamed student'
                                            : fullName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Display ID',
                                        style: theme.textTheme.labelMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        studentProfile.displayId,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // 💡 Pass the flattened top-level ledger down cleanly here
                            _LedgerPanel(
                              ledgerAsync: ledgerAsync,
                              onLogPayment: () => _showLogPaymentDialog(
                                studentId: studentProfile.studentId,
                                studentDisplayId: studentProfile.displayId,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// 💡 NEW COMPONENT: Encapsulates form text state to guarantee perfect rendering lifecycles
class _PaymentDialog extends StatefulWidget {
  final String studentDisplayId;
  final String studentId;

  const _PaymentDialog({
    required this.studentDisplayId,
    required this.studentId,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentIdController;
  final _semesterController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _paymentMethodController = TextEditingController(text: 'Cash');

  @override
  void initState() {
    super.initState();
    _studentIdController = TextEditingController(text: widget.studentId);
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _semesterController.dispose();
    _paymentAmountController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Log payment for ${widget.studentDisplayId}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Student ID is required.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _semesterController,
                  decoration: const InputDecoration(labelText: 'Semester'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Semester is required.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _paymentAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed <= 0)
                      return 'Enter a valid payment amount.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _paymentMethodController,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Payment method is required.'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              _PaymentFormValues(
                studentId: _studentIdController.text.trim(),
                semester: _semesterController.text.trim(),
                paymentAmount: double.parse(
                  _paymentAmountController.text.trim(),
                ),
                paymentMethod: _paymentMethodController.text.trim(),
              ),
            );
          },
          child: const Text('Save Payment'),
        ),
      ],
    );
  }
}

class _PaymentFormValues {
  const _PaymentFormValues({
    required this.studentId,
    required this.semester,
    required this.paymentAmount,
    required this.paymentMethod,
  });

  final String studentId;
  final String semester;
  final double paymentAmount;
  final String paymentMethod;
}

class _LedgerPanel extends StatelessWidget {
  const _LedgerPanel({required this.ledgerAsync, required this.onLogPayment});

  final AsyncValue<List<LedgerEntryDTO>> ledgerAsync;
  final VoidCallback onLogPayment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ledgerAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Text(
        'Error loading ledger statement: $error',
        style: theme.textTheme.bodyMedium,
      ),
      data: (entries) {
        final sortedEntries = [...entries]
          ..sort((left, right) => left.date.compareTo(right.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LedgerTableHeader(),
            const SizedBox(height: 8),
            if (sortedEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Text(
                  'No ledger entries found for this student.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedEntries.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final entry = sortedEntries[index];
                  return _LedgerTableRow(entry: entry, index: index);
                },
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onLogPayment,
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Log Student Payment'),
            ),
          ],
        );
      },
    );
  }
}

class _LedgerTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Expanded(flex: 2, child: _HeaderCell(label: 'Date')),
          Expanded(flex: 2, child: _HeaderCell(label: 'Semester')),
          Expanded(flex: 4, child: _HeaderCell(label: 'Particulars')),
          Expanded(flex: 2, child: _HeaderCell(label: 'Debit')),
          Expanded(flex: 2, child: _HeaderCell(label: 'Credit')),
          Expanded(flex: 2, child: _HeaderCell(label: 'Balance')),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _LedgerTableRow extends StatelessWidget {
  const _LedgerTableRow({required this.entry, required this.index});

  final LedgerEntryDTO entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowBackground = index.isEven
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: rowBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _LedgerCell(value: formatDate(entry.date))),
          Expanded(flex: 2, child: _LedgerCell(value: entry.semester)),
          Expanded(flex: 4, child: _LedgerCell(value: entry.particulars)),
          Expanded(
            flex: 2,
            child: _LedgerCell(value: entry.debit.toStringAsFixed(2)),
          ),
          Expanded(
            flex: 2,
            child: _LedgerCell(value: entry.credit.toStringAsFixed(2)),
          ),
          Expanded(
            flex: 2,
            child: _LedgerCell(value: entry.balance.toStringAsFixed(2)),
          ),
        ],
      ),
    );
  }
}

class _LedgerCell extends StatelessWidget {
  const _LedgerCell({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
