import 'package:intl/intl.dart';

class DateUtil {
  static String formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }
}
