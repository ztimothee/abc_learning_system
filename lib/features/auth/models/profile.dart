import 'dart:core';

import 'package:abc_learning_system/core/themes/status_map.dart';

Map<String, String> staffData = {
  'teacher': 'Teacher',
  'admin': 'Admin',
  'counselor': 'Counselor',
  'librarian': 'Librarian',
  'registrar': 'Registrar',
};

class Profile {
  final String? userId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String contactNumber;
  final String address;
  final int civilStatus;
  final String role;
  final String? position;
  final DateTime? createdAt;

  Profile({
    this.userId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.address,
    required this.civilStatus,
    required this.role,
    this.position,
    this.createdAt,
  });

  // Factory constructor to create a Profile instance from a map retrieved from the database
  factory Profile.fromMap(Map<String, dynamic> map) {
    final dynamic staffRelation = map['staffs'];
    final Map<String, dynamic>? staffData =
        staffRelation is Map<String, dynamic>
        ? staffRelation
        : staffRelation is List && staffRelation.isNotEmpty
        ? staffRelation.first as Map<String, dynamic>
        : null;
    final dynamic rawCivilStatus = map['civil_status'];
    final int parsedCivilStatus = rawCivilStatus is int
        ? rawCivilStatus
        : (rawCivilStatus?.toString() ?? 'Single').civilStatusValue;

    return Profile(
      userId: map['user_id'] ?? '',
      firstName: map['first_name'] ?? '',
      middleName: map['middle_name'],
      lastName: map['last_name'] ?? '',
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      gender: map['gender'] ?? '',
      contactNumber: map['contact_number'] ?? '',
      address: map['address'] ?? '',
      civilStatus: parsedCivilStatus,
      role: map['role'] ?? 'student',
      position: staffData != null ? staffData['position'] as String? : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  // Method to convert a Profile instance to a map to submit to the database
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'contact_number': contactNumber,
      'address': address,
      'civil_status': civilStatus,
      'created_at': createdAt?.toIso8601String(),
      'role': role,
      if (position != null) 'position': position,
    };
  }
}
