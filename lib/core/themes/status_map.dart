extension CivilStatusMap on int {
  String get civilStatus {
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
  int get civilStatusValue {
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

extension CurrentRoleMap on int {
  String get currentRole {
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
  int get currentRoleValue {
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

extension EnrollmentStatusMap on int {
  String get enrollmentStatus {
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
  int get enrollmentStatusValue {
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