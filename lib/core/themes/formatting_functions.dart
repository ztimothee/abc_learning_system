
  import 'package:abc_learning_system/features/auth/models/profile.dart';

String buildFullName(Profile profile) {
  final parts = [
    profile.firstName,
    if (profile.middleName != null && profile.middleName!.trim().isNotEmpty)
      profile.middleName!.trim(),
    profile.lastName,
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