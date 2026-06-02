import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/features/accounts_ledgers/models/ledger_entry_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountsLedgersRepository {
  final SupabaseClient supabase;

  AccountsLedgersRepository(this.supabase);

  Future<List<LedgerEntryDTO>> fetchStudentStatement(String studentId) async {
    final List<Map<String, dynamic>> response = await supabase
        .from('student_ledger_view')
        .select()
        .eq('student_id', studentId)
        .order('date', ascending: true); // Chronological view order

    return response.map((data) => LedgerEntryDTO.fromMap(data)).toList();
  }

  Future<void> logStudentPayment({
    required String studentId,
    required String semester,
    required double paymentAmount,
    required String paymentMethod, // e.g., "Cash", "GCash", "Bank Transfer"
  }) async {
    await supabase.from('student_ledgers').insert({
      'student_id': studentId,
      'semester': semester,
      'particulars': 'Payment Received ($paymentMethod)',
      'debit': 0,
      'credit': paymentAmount, // 💡 Increases credit, lowering total balance
    });
  }
}

final accountsLedgersRepositoryProvider = Provider<AccountsLedgersRepository>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return AccountsLedgersRepository(supabase);
});

final studentLedgerStatementProvider =
    FutureProvider.family<List<LedgerEntryDTO>, String>((ref, studentId) async {
      final repository = ref.watch(accountsLedgersRepositoryProvider);
      return repository.fetchStudentStatement(studentId);
    });

class AccountsLedgersOperationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initialization needed for this controller
    return;
  }

  Future<void> logPayment({
    required String studentId,
    required String semester,
    required double paymentAmount,
    required String paymentMethod,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(accountsLedgersRepositoryProvider);
      await repository.logStudentPayment(
        studentId: studentId,
        semester: semester,
        paymentAmount: paymentAmount,
        paymentMethod: paymentMethod,
      );
      ref.invalidate(studentLedgerStatementProvider(studentId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final accountsLedgersOperationControllerProvider =
    AsyncNotifierProvider<AccountsLedgersOperationController, void>(
  () => AccountsLedgersOperationController(),
);
