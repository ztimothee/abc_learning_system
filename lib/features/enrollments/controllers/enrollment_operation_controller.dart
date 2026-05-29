import 'dart:async';

import 'package:abc_learning_system/features/enrollments/controllers/enrollment_repository.dart';
import 'package:abc_learning_system/shared/students/controllers/student_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnrollmentOperationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {
    // No initialization needed for this controller
    return null;
  }

  Future<void> enrollStudentInSubject(String studentId, String subjectId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(enrollmentRepositoryProvider);
      await repository.enrollStudentInSubject(studentId: studentId, subjectId: subjectId);
      ref.invalidate(enrollmentRepositoryProvider);
      ref.invalidate(studentEnrollmentSummaryProvider(studentId));
      ref.invalidate(studentRepositoryProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Error enrolling student: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> batchEnrollStudentInSubjects(String studentId, String batchId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(enrollmentRepositoryProvider);
      await repository.batchEnrollStudentInSubjects(studentId: studentId, batchId: batchId);
      ref.invalidate(enrollmentRepositoryProvider);
      ref.invalidate(studentEnrollmentSummaryProvider(studentId));
      ref.invalidate(studentRepositoryProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Error batch enrolling student: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateEnrollmentStatus(String enrollmentId, int newStatus) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(enrollmentRepositoryProvider);
      await repository.updateEnrollmentStatus(enrollmentId: enrollmentId, newStatus: newStatus);
      ref.invalidate(enrollmentRepositoryProvider);
      ref.invalidate(studentRepositoryProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Error updating enrollment status: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateMultipleEnrollmentStatus(List<String> enrollmentIds, int newStatus) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(enrollmentRepositoryProvider);
      await repository.updateMultipleEnrollmentStatus(enrollmentIds: enrollmentIds, newStatus: newStatus);
      ref.invalidate(enrollmentRepositoryProvider);
      ref.invalidate(studentRepositoryProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Error updating multiple enrollment statuses: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final enrollmentOperationControllerProvider =
    AsyncNotifierProvider<EnrollmentOperationController, void>(
  () => EnrollmentOperationController(),
);