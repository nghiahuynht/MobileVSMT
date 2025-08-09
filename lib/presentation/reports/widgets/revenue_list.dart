import 'package:flutter/material.dart';
import 'package:trash_pay/domain/entities/report/monthly_revenue.dart';

class RevenueSummaryTable extends StatelessWidget {
  final List<MonthlyRevenue> data;
  final Function(MonthlyRevenue)? onRowTap;
  final bool isExpanded;
  final bool isDaily;

  const RevenueSummaryTable({
    super.key,
    required this.data,
    this.onRowTap,
    this.isExpanded = false,
    this.isDaily = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, thickness: 1),
          // isExpanded ?
          // Expanded(
          //   child: ListView.builder(
          //     padding: EdgeInsets.zero,
          //     itemBuilder: (context, index) => _buildRow(data[index]),
          //   ),
          // )
          if (!isExpanded) ...data.map(_buildRow).toList(),

          if (isExpanded)
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom),
                itemBuilder: (context, index) => _buildRow(data[index]),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(isDaily ? 'Ngày' : 'Tháng',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const Expanded(
            flex: 3,
            child: Text('Doanh thu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.right),
          ),
          if (onRowTap != null)
            Expanded(
              child: Container(),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(MonthlyRevenue item) {
    return InkWell(
      onTap: () => onRowTap?.call(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('${isDaily ? 'Ngày' : 'Tháng'} ${item.label}',
                  style: const TextStyle(fontSize: 14)),
            ),
            Expanded(
              flex: 3,
              child: Text(_formatVND(item.revenue ?? 0),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  textAlign: TextAlign.right),
            ),
            if (onRowTap != null)
              const Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_circle_right_outlined,
                    color: Color(0xFF059669),
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatVND(num amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
  }
}
