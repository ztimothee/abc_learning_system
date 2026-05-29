import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:flutter/material.dart';

String buildFullName(String firstName, String? middleName, String lastName) {
  final parts = [
    firstName,
    if (middleName != null && middleName.trim().isNotEmpty) middleName.trim(),
    lastName,
  ];

  return parts.join(' ');
}

String buildFullNameSurnameFirst(
  String firstName,
  String? middleName,
  String lastName,
) {
  final parts = [
    "$lastName, $firstName",
    if (middleName != null && middleName.trim().isNotEmpty) middleName.trim(),
  ];

  return parts.join(' ');
}

String buildInitials(Profile profile) {
  final first = profile.firstName.trim();
  final last = profile.lastName.trim();
  final firstChar = first.isNotEmpty ? first[0] : '';
  final lastChar = last.isNotEmpty ? last[0] : '';
  final initials = (firstChar + lastChar).toUpperCase();

  return initials.isEmpty ? '?' : initials;
}

String formatDate(DateTime date) {
  final local = date.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

Color darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  final l = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}
