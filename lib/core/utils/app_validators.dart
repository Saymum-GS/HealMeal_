class AppValidators {
  static String? bdPhone(String? value) => bangladeshPhone(value);

  static String? bangladeshPhone(String? value) {
    final text = value?.trim() ?? '';
    final normalized = text.startsWith('+880') ? '0${text.substring(4)}' : text;
    final regex = RegExp(r'^01[3-9][0-9]{8}$');
    if (normalized.isEmpty) return 'Phone number is required';
    if (!regex.hasMatch(normalized)) {
      return 'Enter a valid Bangladeshi phone number';
    }
    return null;
  }

  static String? requiredField(
    String? value, {
    String message = 'This field is required',
  }) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }

  static String? required(String? value) => requiredField(value);

  static String? otp(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'OTP is required';
    if (text.length != 6) return 'Enter a valid 6-digit OTP';
    return null;
  }
}

