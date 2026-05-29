import 'package:flutter/material.dart';

// === Status Maps for Civil Status ===========================================================================

extension CivilStatusMap on int {
  String get civilStatusString {
    switch (this) {
      case 0:
        return 'Single';
      case 1:
        return 'Married';
      case 2:
        return 'Divorced';
      case 3:
        return 'Widowed/Widower';
      default:
        return 'Unknown';
    }
  }
}

extension CivilStatusStringMap on String {
  int get civilStatusInt {
    switch (this) {
      case 'Single':
        return 0;
      case 'Married':
        return 1;
      case 'Divorced':
        return 2;
      case 'Widowed/Widower':
        return 3;
      default:
        return -1; // Unknown
    }
  }
}

// === Status Maps for User Roles ===========================================================================

extension CurrentRoleMap on int {
  String get currentRoleString {
    switch (this) {
      case 0:
        return 'student';
      case 1:
        return 'tutor';
      case 2:
        return 'staff';
      default:
        return 'Unknown';
    }
  }
}

extension CurrentRoleStringMap on String {
  int get currentRoleInt {
    switch (this) {
      case 'student':
        return 0;
      case 'tutor':
        return 1;
      case 'staff':
        return 2;
      default:
        return -1; // Unknown
    }
  }
}

// === Status Maps for Enrollment ===========================================================================

extension EnrollmentStatusMap on int {
  String get enrollmentStatusString {
    switch (this) {
      case 0:
        return 'Admin-Assigned';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Paid';
      case 3:
        return 'Finished';
      case 4:
        return 'Incomplete';
      case 5:
        return 'Dropped';
      default:
        return 'Unknown';
    }
  }
}

extension EnrollmentStatusStringMap on String {
  int get enrollmentStatusInt {
    switch (this) {
      case 'Admin-Assigned':
        return 0;
      case 'Confirmed':
        return 1;
      case 'Paid':
        return 2;
      case 'Finished':
        return 3;
      case 'Incomplete':
        return 4;
      case 'Dropped':
        return 5;
      default:
        return -1; // Unknown
    }
  }
}

extension EnrollmentStatusColorMap on int {
  Color get enrollmentStatusColor {
    switch (this) {
      case 0:
        return Colors.orange; // Admin-Assigned
      case 1:
        return Colors.blue; // Confirmed
      case 2:
        return Colors.green; // Paid
      case 3:
        return Colors.purple; // Finished
      case 4:
        return Colors.yellow; // Incomplete
      case 5:
        return Colors.red; // Dropped
      default:
        return Colors.grey; // Unknown
    }
  }
}

// === Status Maps for Attendance ===========================================================================

extension AttendanceStatusMap on int {
  String get attendanceStatusString {
    switch (this) {
      case 0:
        return 'Unmarked';
      case 1:
        return 'Present';
      case 2:
        return 'Absent';
      case 3:
        return 'Late';
      case 4:
        return 'Excused';
      default:
        return 'Unknown';
    }
  }
}

extension AttendanceStatusStringMap on String {
  int get attendanceStatusInt {
    switch (this) {
      case 'Unmarked':
        return 0;
      case 'Present':
        return 1;
      case 'Absent':
        return 2;
      case 'Late':
        return 3;
      case 'Excused':
        return 4;
      default:
        return -1; // Unknown
    }
  }
}

extension AttendanceStatusColorMap on int {
  Color get attendanceStatusColor {
    switch (this) {
      case 0:
        return Colors.grey; // Unmarked
      case 1:
        return Colors.green; // Present
      case 2:
        return Colors.red; // Absent
      case 3:
        return Colors.orange; // Late
      case 4:
        return Colors.blue; // Excused
      default:
        return Colors.grey; // Unknown
    }
  }
}
