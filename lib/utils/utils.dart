class Utils {
  /// Format currency
  static String formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = absAmount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return '${isNegative ? '-' : ''}${formatted}đ';
  }

  static int getDaysInMonth(int year, int month) {
    var beginningNextMonth =
        (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
    var lastDayOfThisMonth =
        beginningNextMonth.subtract(const Duration(days: 1));
    return lastDayOfThisMonth.day;
  }
}
