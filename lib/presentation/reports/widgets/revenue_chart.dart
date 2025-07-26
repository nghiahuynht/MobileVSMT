import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trash_pay/domain/entities/report/monthly_revenue.dart';

class RevenueChart extends StatelessWidget {
  final List<MonthlyRevenue> data;
  final int year;

  const RevenueChart({super.key, required this.data, required this.year});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SfCartesianChart(
        title: const ChartTitle(text: 'Biểu đồ doanh thu theo tháng'),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Năm ${year}'),
          interval: 1,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<MonthlyRevenue, String>>[
          ColumnSeries<MonthlyRevenue, String>(
            dataSource: data,
            xValueMapper: (MonthlyRevenue item, _) => item.label,
            yValueMapper: (MonthlyRevenue item, _) => item.revenueMillion,
            name: 'Doanh thu',
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}
