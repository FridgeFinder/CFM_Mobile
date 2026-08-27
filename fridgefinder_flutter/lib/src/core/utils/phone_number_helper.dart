/// Utility class for phone number formatting and validation
class PhoneNumberHelper {
  /// Format a US/Canada phone number to E.164 format (required by Firebase).
  /// Accepts either 10 digits or 11 digits starting with 1.
  static String? formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) return null;

    // If it starts with 1 and has 11 digits, it's US/Canada with country code
    if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      return '+$digitsOnly';
    }

    // If it has 10 digits, assume US/Canada and add +1
    if (digitsOnly.length == 10) {
      return '+1$digitsOnly';
    }

    return null;
  }

  /// Validate a US/Canada phone number.
  static bool isValidPhoneNumber(String phoneNumber) {
    return formatPhoneNumber(phoneNumber) != null;
  }

  /// Format phone number for display
  static String formatForDisplay(String phoneNumber) {
    final formatted = formatPhoneNumber(phoneNumber);
    if (formatted == null) return phoneNumber;

    // Format US numbers: +1 (234) 567-8900
    if (formatted.startsWith('+1') && formatted.length == 12) {
      final areaCode = formatted.substring(2, 5);
      final firstPart = formatted.substring(5, 8);
      final secondPart = formatted.substring(8);
      return '+1 ($areaCode) $firstPart-$secondPart';
    }

    return formatted;
  }
}

