/// Utility class for phone number formatting and validation
class PhoneNumberHelper {
  /// Format phone number to E.164 format (required by Firebase)
  /// Example: "+1234567890" or "+11234567890"
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
    
    // If it already starts with +, return as is (after cleaning)
    if (phoneNumber.trim().startsWith('+')) {
      return '+$digitsOnly';
    }
    
    // Otherwise, return with + prefix
    return '+$digitsOnly';
  }
  
  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    final formatted = formatPhoneNumber(phoneNumber);
    if (formatted == null) return false;
    
    // E.164 format: + followed by 1-15 digits
    final e164Pattern = RegExp(r'^\+\d{1,15}$');
    return e164Pattern.hasMatch(formatted);
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

