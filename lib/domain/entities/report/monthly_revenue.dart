import 'dart:convert';

class MonthlyRevenue {
  final String? label;
  final double? revenue;
  final int? totalCustomer;

  const MonthlyRevenue({
    required this.label,
    this.revenue = 0,
    this.totalCustomer = 0,
  });

  double get revenueMillion => (revenue ?? 0) / 1000000;

  MonthlyRevenue copyWith({
    String? label,
    double? revenue,
    int? totalCustomer,
  }) {
    return MonthlyRevenue(
      label: label ?? this.label,
      revenue: revenue ?? this.revenue,
      totalCustomer: totalCustomer ?? this.totalCustomer,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'revenue': revenue,
      'totalCustomer': totalCustomer,
    };
  }

  factory MonthlyRevenue.fromMonthMap(Map<String, dynamic> map) {
    return MonthlyRevenue(
      label: map['month'] != null ? (map['month'] as int).toString() : null,
      revenue: map['totalRevenue'] != null ? (map['totalRevenue'] as double) : null,
      totalCustomer: map['totalCustomer'] != null ? (map['totalCustomer'] as int) : null,
    );
  }


  factory MonthlyRevenue.fromDailyMap(Map<String, dynamic> map) {
    return MonthlyRevenue(
      label: map['day'] != null ? (map['day'] as int?)?.toString() ?? '0' : null,
      revenue: map['totalRevenue'] != null ? (map['totalRevenue'] as double) : null,
      totalCustomer: map['totalCustomer'] != null ? (map['totalCustomer'] as int) : null,
    );
  }


  String toJson() => json.encode(toMap());

  @override
  String toString() => 'MonthlyRevenue(label: $label, revenue: $revenue, totalCustomer: $totalCustomer)';

  @override
  bool operator ==(covariant MonthlyRevenue other) {
    if (identical(this, other)) return true;
  
    return 
      other.label == label &&
      other.revenue == revenue &&
      other.totalCustomer == totalCustomer;
  }

  @override
  int get hashCode => label.hashCode ^ revenue.hashCode ^ totalCustomer.hashCode;
}
