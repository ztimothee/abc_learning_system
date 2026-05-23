import 'dart:core';

class Profile {
  final String userId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String contactNumber;
  final String address;
  final int civilStatus;
  final DateTime? createdAt;

  Profile({
    required this.userId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.address,
    required this.civilStatus,
    this.createdAt,
  });

  // Factory constructor to create a Profile instance from a map retrieved from the database
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      userId: map['user_id'],
      firstName: map['first_name'],
      middleName: map['middle_name'],
      lastName: map['last_name'],
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      gender: map['gender'],
      contactNumber: map['contact_number'],
      address: map['address'],
      civilStatus: map['civil_status'],
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
    };
  }
}
