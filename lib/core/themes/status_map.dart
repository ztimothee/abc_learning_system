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
