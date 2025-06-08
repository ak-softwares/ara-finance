import 'package:intl/intl.dart';

class AppFormatter {

  static String formatDateSmall(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM').format(date); // e.g., 01/06
  }

  static String formatDate(DateTime? date) {
    if(date == null){
      return '';
    }
    return DateFormat('dd, MMM yyyy').format(date);
  }

  static String formatStringDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd, MMMM yyyy').format(dateTime);
    } catch (e) {
      return 'N/A'; // Handle invalid date format cases
    }
  }


  static String maskEmail(String email) {
    // Split email into username and domain
    List<String> parts = email.split('@');
    if (parts.length != 2) {
      // Invalid email format
      return email;
    }

    String username = parts[0];
    String domain = parts[1];

    // Extract first two characters
    String firstTwo = username.substring(0, 2);

    // Extract last two characters
    String lastTwo = username.substring(username.length - 2);

    return '$firstTwo***$lastTwo@$domain';
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    //Assuming a 10-digit US phone number format: (123) 456-7895
    if(phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6) }';
    }else if(phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7) }';
    }
    return phoneNumber;
  }
}