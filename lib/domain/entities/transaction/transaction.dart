enum TransactionType {
  deposit,    // Nạp tiền
  withdraw,   // Rút tiền
  purchase,   // Mua hàng
  refund,     // Hoàn tiền
  bonus,      // Thưởng
  penalty,    // Phạt
}

enum TransactionStatus {
  pending,    // Chờ xử lý
  completed,  // Hoàn thành
  failed,     // Thất bại
  cancelled,  // Đã hủy
}

class TransactionModel {
  final String id;
  final String customerId;
  final String customerName;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final DateTime createdAt;
  final String? orderId;      // ID đơn hàng liên quan (nếu có)
  final String? reference;    // Mã tham chiếu
  final String createdBy;     // Người tạo giao dịch

  const TransactionModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
    this.orderId,
    this.reference,
    required this.createdBy,
  });

  TransactionModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    String? description,
    DateTime? createdAt,
    String? orderId,
    String? reference,
    String? createdBy,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      reference: reference ?? this.reference,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.deposit:
        return 'Nạp tiền';
      case TransactionType.withdraw:
        return 'Rút tiền';
      case TransactionType.purchase:
        return 'Mua hàng';
      case TransactionType.refund:
        return 'Hoàn tiền';
      case TransactionType.bonus:
        return 'Thưởng';
      case TransactionType.penalty:
        return 'Phạt';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.pending:
        return 'Chờ xử lý';
      case TransactionStatus.completed:
        return 'Hoàn thành';
      case TransactionStatus.failed:
        return 'Thất bại';
      case TransactionStatus.cancelled:
        return 'Đã hủy';
    }
  }

  bool get isCredit {
    return type == TransactionType.deposit || 
           type == TransactionType.refund || 
           type == TransactionType.bonus;
  }

  bool get isDebit {
    return type == TransactionType.withdraw || 
           type == TransactionType.purchase || 
           type == TransactionType.penalty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TransactionModel{id: $id, customerId: $customerId, amount: $amount, type: $type, status: $status}';
  }
} 