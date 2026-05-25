import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentAccountLedgersScreen extends ConsumerStatefulWidget {
  const StudentAccountLedgersScreen({super.key});

  @override
  ConsumerState<StudentAccountLedgersScreen> createState() => _StudentAccountLedgersScreenState();
}

class _StudentAccountLedgersScreenState extends ConsumerState<StudentAccountLedgersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Account Ledgers')),
      body: const Center(child: Text('Student Account Ledgers content goes here.')),
    );
  }
}
