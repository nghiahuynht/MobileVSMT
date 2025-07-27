import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trash_pay/constants/colors.dart';
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
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        axes: const <ChartAxis>[
          NumericAxis(
            name: 'secondaryY',
            opposedPosition: true,
            majorGridLines: const MajorGridLines(width: 0),
            minorGridLines: const MinorGridLines(width: 0),
            majorTickLines: const MajorTickLines(width: 0),
            minorTickLines: const MinorTickLines(width: 0),
          ),
        ],
        series: <CartesianSeries<MonthlyRevenue, String>>[
          ColumnSeries<MonthlyRevenue, String>(
            dataSource: data,
            xValueMapper: (MonthlyRevenue item, _) => item.label,
            yValueMapper: (MonthlyRevenue item, _) => item.totalCustomer,
            name: 'Số lượng KH',
            dataLabelSettings: const DataLabelSettings(
              isVisible: false,
            ),
          ),
          LineSeries<MonthlyRevenue, String>(
            dataSource: data,
            xValueMapper: (MonthlyRevenue item, _) => item.label,
            yValueMapper: (MonthlyRevenue item, _) => item.revenueMillion,
            yAxisName: 'secondaryY',
            name: 'Doanh thu (triệu đồng)',
            dataLabelSettings: const DataLabelSettings(
              isVisible: false,
            ),
            markerSettings: const MarkerSettings(
              isVisible: true,
              shape: DataMarkerType.circle,
              color: AppColors.primary,
              borderColor: AppColors.primary,
              width: 6,
              height: 6
            ),
          ),
        ],
      ),
    );
  }
}
