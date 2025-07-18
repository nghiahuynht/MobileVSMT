import 'package:flutter/material.dart';
import '../../../constants/font_family.dart';

class StatisticTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color? textColor;
  final String? trend; // '+12.5%', '-5.2%', etc.
  final bool? isTrendPositive;
  final VoidCallback? onTap;

  const StatisticTile({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.textColor,
    this.trend,
    this.isTrendPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
            // Header with icon and trend
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                if (trend != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isTrendPositive ?? true) 
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (isTrendPositive ?? true) 
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 12,
                          color: (isTrendPositive ?? true) 
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trend!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: (isTrendPositive ?? true) 
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                            fontFamily: FontFamily.productSans,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: textColor ?? const Color(0xFF1F2937),
                fontFamily: FontFamily.productSans,
                letterSpacing: -0.5,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
                fontFamily: FontFamily.productSans,
              ),
            ),
            
            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                  fontFamily: FontFamily.productSans,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Helper functions for creating specialized statistic tiles
class StatisticTileHelpers {
  static StatisticTile revenue({
    required String value,
    String? trend,
    bool? isTrendPositive,
    VoidCallback? onTap,
  }) {
    return StatisticTile(
      title: 'Tổng doanh thu',
      value: value,
      icon: Icons.trending_up_rounded,
      iconColor: const Color(0xFF059669),
      backgroundColor: const Color(0xFFDCFCE7),
      trend: trend,
      isTrendPositive: isTrendPositive,
      onTap: onTap,
    );
  }

  static StatisticTile order({
    required String value,
    String? subtitle,
    String? trend,
    bool? isTrendPositive,
    VoidCallback? onTap,
  }) {
    return StatisticTile(
      title: 'Đơn hàng',
      value: value,
      subtitle: subtitle,
      icon: Icons.assignment_outlined,
      iconColor: const Color(0xFF0EA5E9),
      backgroundColor: const Color(0xFFDEF7FF),
      trend: trend,
      isTrendPositive: isTrendPositive,
      onTap: onTap,
    );
  }

  static StatisticTile customer({
    required String value,
    String? subtitle,
    String? trend,
    bool? isTrendPositive,
    VoidCallback? onTap,
  }) {
    return StatisticTile(
      title: 'Khách hàng',
      value: value,
      subtitle: subtitle,
      icon: Icons.people_outline,
      iconColor: const Color(0xFF7C3AED),
      backgroundColor: const Color(0xFFF3E8FF),
      trend: trend,
      isTrendPositive: isTrendPositive,
      onTap: onTap,
    );
  }

  static StatisticTile profit({
    required String value,
    String? subtitle,
    String? trend,
    bool? isTrendPositive,
    VoidCallback? onTap,
  }) {
    return StatisticTile(
      title: 'Lợi nhuận',
      value: value,
      subtitle: subtitle,
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFFDC2626),
      backgroundColor: const Color(0xFFFEE2E2),
      trend: trend,
      isTrendPositive: isTrendPositive,
      onTap: onTap,
    );
  }
} 