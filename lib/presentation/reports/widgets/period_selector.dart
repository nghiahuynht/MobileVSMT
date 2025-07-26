import 'package:flutter/material.dart';
import '../../../constants/font_family.dart';
import '../../../domain/entities/report/report_period.dart';

class PeriodSelector extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final Function(ReportPeriod) onPeriodChanged;
  final bool isLoading;

  PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                'Thời gian báo cáo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                  fontFamily: FontFamily.productSans,
                ),
              ),
              const Spacer(),
              if (isLoading) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Period buttons grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPeriodChip(ReportPeriod.thisYear),
              _buildPeriodChip(ReportPeriod.lastYear),
            ],
          ),
          
          // Ẩn nút chọn khoảng thời gian tùy chọn
          // const SizedBox(height: 12),
          // SizedBox(
          //   width: double.infinity,
          //   child: OutlinedButton.icon(
          //     onPressed: () => _showCustomDatePicker(context),
          //     icon: const Icon(
          //       Icons.date_range_outlined,
          //       size: 16,
          //       color: Color(0xFF059669),
          //     ),
          //     label: Text(
          //       selectedPeriod == ReportPeriod.custom 
          //           ? 'Khoảng thời gian tùy chọn'
          //           : 'Chọn khoảng thời gian',
          //       style: TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.w500,
          //         color: const Color(0xFF059669),
          //         fontFamily: FontFamily.productSans,
          //       ),
          //     ),
          //     style: OutlinedButton.styleFrom(
          //       side: const BorderSide(color: Color(0xFF059669), width: 1),
          //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(ReportPeriod period) {
    final isSelected = selectedPeriod == period;
    
    return GestureDetector(
      onTap: isLoading ? null : () => onPeriodChanged(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF059669)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF059669)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          period.displayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected 
                ? Colors.white
                : const Color(0xFF6B7280),
            fontFamily: FontFamily.productSans,
          ),
        ),
      ),
    );
  }

  void _showCustomDatePicker(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedPeriod == ReportPeriod.custom
          ? DateTimeRange(
              start: selectedPeriod.dateRange.start,
              end: selectedPeriod.dateRange.end.subtract(const Duration(days: 1)),
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF059669),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      // Convert DateTimeRange to our custom DateRange and trigger callback
      onPeriodChanged(ReportPeriod.custom);
      // Note: In a real implementation, you'd want to pass the custom range 
      // to the callback as well, perhaps through a different method
    }
  }
} 