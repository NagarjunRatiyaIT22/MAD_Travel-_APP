import 'package:intl/intl.dart';

/// Utility formatting helpers used across the app.
class Formatters {
  Formatters._();

  static String currency(double amount, {String symbol = '₹'}) {
    final f = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return f.format(amount);
  }

  static String currencyShort(double amount, {String symbol = '₹'}) {
    if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String dateShort(DateTime d) => DateFormat('dd MMM').format(d);
  static String dateRange(DateTime start, DateTime end) =>
      '${dateShort(start)} - ${dateShort(end)}, ${DateFormat('yyyy').format(end)}';
  static String timeOfDay(DateTime d) => DateFormat('hh:mm a').format(d);
  static String dayLabel(DateTime d) => DateFormat('EEEE').format(d);
  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);

  static String daysLeft(DateTime target) {
    final diff = target.difference(DateTime.now()).inDays;
    if (diff < 0) return '${-diff}d ago';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return 'In $diff days';
  }

  static String relativeTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(d);
  }
}
