import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/features/accounts_ledgers/controllers/accounts_ledgers_repository.dart';
import 'package:abc_learning_system/features/accounts_ledgers/models/ledger_entry_dto.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:abc_learning_system/shared/widgets/app_loading_screen.dart';
import 'package:abc_learning_system/shared/widgets/header_card.dart';
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
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Student Account Ledgers')),
      body: profileAsync.when(
        loading: () => const AppLoadingScreen(),
        error: (error, _) =>
            Center(child: Text('Error loading profile: $error')),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text(
                'No student profile is available for the current user.',
              ),
            );
          }

          final userId = profile.userId;
          if (userId == null || userId.isEmpty) {
            return const Center(
              child: Text('No student ID is available for the current user.'),
            );
          }

          return ref
              .watch(studentProfileByUserIdProvider(userId))
              .when(
                loading: () => const AppLoadingScreen(),
                error: (error, _) => Center(
                  child: Text('Error loading student profile: $error'),
                ),
                data: (studentProfile) {
                  final fullName = buildFullName(
                    studentProfile.firstName,
                    studentProfile.middleName,
                    studentProfile.lastName,
                  );

                  return ref
                      .watch(
                        studentLedgerStatementProvider(
                          studentProfile.studentId,
                        ),
                      )
                      .when(
                        loading: () => const AppLoadingScreen(),
                        error: (error, _) => Center(
                          child: Text('Error loading ledger statement: $error'),
                        ),
                        data: (entries) {
                          final sortedEntries = [...entries]
                            ..sort(
                              (left, right) => left.date.compareTo(right.date),
                            );

                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).colorScheme.surface,
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                ],
                              ),
                            ),
                            child: SafeArea(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  20,
                                  20,
                                  32,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1200,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        HeaderCard(
                                          title: 'Student Account Ledgers',
                                          id: studentProfile.displayId,
                                          name: fullName,
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            border: Border.all(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.outlineVariant,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x0F0F172A),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              _LedgerTableHeader(),
                                              const SizedBox(height: 8),
                                              if (sortedEntries.isEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 28,
                                                      ),
                                                  child: Text(
                                                    'No ledger entries found for this student.',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              else
                                                ListView.separated(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      sortedEntries.length,
                                                  separatorBuilder: (_, __) =>
                                                      const Divider(height: 12),
                                                  itemBuilder: (context, index) {
                                                    final entry =
                                                        sortedEntries[index];
                                                    return _LedgerTableRow(
                                                      entry: entry,
                                                      index: index,
                                                    );
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
        children: [
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
