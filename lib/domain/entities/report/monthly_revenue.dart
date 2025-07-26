class MonthlyRevenue {
  final String label;
  final double revenue;
  final int totalCustomer;

  const MonthlyRevenue({
    required this.label,
    this.revenue = 0,
    this.totalCustomer = 0,
  });

  double get revenueMillion => revenue / 1000000;
}
