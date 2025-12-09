class Validators {
  // ITS Number validation
  static String? validateITS(String? value) {
    if (value == null || value.isEmpty) {
      return 'ITS number is required';
    }
    if (value.length != 8) {
      return 'ITS number must be 8 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'ITS number must contain only digits';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Mobile number validation
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length < 10) {
      return 'Invalid mobile number';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Mobile number must contain only digits';
    }
    return null;
  }

  // Item name validation
  static String? validateItemName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Item name is required';
    }
    if (value.length < 2) {
      return 'Item name must be at least 2 characters';
    }
    return null;
  }

  // Mohallah name validation
  static String? validateMohallahName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohallah name is required';
    }
    return null;
  }

  // Booking limit validation
  static String? validateBookingLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Booking limit is required';
    }
    final limit = int.tryParse(value);
    if (limit == null || limit < 1 || limit > 10) {
      return 'Booking limit must be between 1 and 10';
    }
    return null;
  }
}