import 'package:flutter/material.dart';

enum OrderStatus {
  waiting,
  approved,
  canceled;

  String get statusDisplayName {
    switch (this) {
      case OrderStatus.waiting:
        return 'Chờ duyệt';
      case OrderStatus.approved:
        return 'Đã duyệt';
      case OrderStatus.canceled:
        return 'Đã hủy';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.waiting:
        return const Color(0xffffa301);
      case OrderStatus.approved:
        return const Color(0xFF059669);
      case OrderStatus.canceled:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.waiting:
        return Icons.edit_outlined;
      case OrderStatus.approved:
        return Icons.check_circle_outline;
      case OrderStatus.canceled:
        return Icons.cancel_outlined;
    }
  }

  static OrderStatus fromMap(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.waiting,
    );
  }
}
