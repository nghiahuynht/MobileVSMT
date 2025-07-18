class ReceiptData {
  final String companyName;
  final String address;
  final String phone;
  final String orderNumber;
  final DateTime orderDate;
  final String customerName;
  final List<ReceiptItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String? notes;

  const ReceiptData({
    required this.companyName,
    required this.address,
    required this.phone,
    required this.orderNumber,
    required this.orderDate,
    required this.customerName,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    this.notes,
  });
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });
}

class ReceiptTemplate {
  static const int _maxLineLength = 32;
  static const String _divider = '--------------------------------';
  static const String _doubleDivider = '================================';

  /// Generate text receipt for thermal printer
  static String generateTextReceipt(ReceiptData data) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(_centerText(data.companyName));
    buffer.writeln(_centerText(data.address));
    buffer.writeln(_centerText('Tel: ${data.phone}'));
    buffer.writeln(_divider);
    buffer.writeln();

    // Title
    buffer.writeln(_centerText('HÓA ĐƠN BÁN HÀNG'));
    buffer.writeln();

    // Order Info
    buffer.writeln('Số HĐ: ${data.orderNumber}');
    buffer.writeln('Ngày: ${_formatDateTime(data.orderDate)}');
    buffer.writeln('KH: ${data.customerName}');
    buffer.writeln(_divider);

    // Items Header
    buffer.writeln(_formatItemHeader());
    buffer.writeln(_divider);

    // Items
    for (final item in data.items) {
      buffer.writeln(_formatItem(item));
    }

    buffer.writeln(_divider);

    // Totals
    buffer.writeln(_formatTotal('Tạm tính:', data.subtotal));
    
    if (data.discount > 0) {
      buffer.writeln(_formatTotal('Giảm giá:', -data.discount));
    }
    
    if (data.tax > 0) {
      buffer.writeln(_formatTotal('Thuế:', data.tax));
    }
    
    buffer.writeln(_doubleDivider);
    buffer.writeln(_formatTotal('TỔNG CỘNG:', data.total, isFinal: true));
    buffer.writeln(_doubleDivider);

    // Notes
    if (data.notes != null && data.notes!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Ghi chú: ${data.notes}');
      buffer.writeln(_divider);
    }

    // Footer
    buffer.writeln();
    buffer.writeln(_centerText('Cảm ơn quý khách!'));
    buffer.writeln(_centerText('Hẹn gặp lại!'));
    buffer.writeln();
    buffer.writeln();
    buffer.writeln();

    return buffer.toString();
  }

  /// Convert to Map for printer service
  static List<Map<String, dynamic>> toItemList(ReceiptData data) {
    return data.items.map((item) {
      return {
        'name': item.name,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'subtotal': item.subtotal,
      };
    }).toList();
  }

  /// Center text within line length
  static String _centerText(String text) {
    if (text.length >= _maxLineLength) {
      return text.substring(0, _maxLineLength);
    }
    
    final padding = (_maxLineLength - text.length) ~/ 2;
    return '${' ' * padding}$text';
  }

  /// Format date time
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format currency
  static String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = absAmount.toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
    return '${isNegative ? '-' : ''}${formatted}đ';
  }

  /// Format item header
  static String _formatItemHeader() {
    return 'Sản phẩm         SL  Giá     T.Tiền';
  }

  /// Format single item
  static String _formatItem(ReceiptItem item) {
    String name = item.name;
    if (name.length > 15) {
      name = '${name.substring(0, 12)}...';
    }
    
    final qty = item.quantity.toString().padLeft(2);
    final price = _formatCurrency(item.unitPrice);
    final subtotal = _formatCurrency(item.subtotal);
    
    // Build line with proper spacing
    final nameField = name.padRight(15);
    final qtyField = qty.padLeft(2);
    final priceField = price.padLeft(8);
    final subtotalField = subtotal.padLeft(8);
    
    return '${nameField} ${qtyField} ${priceField} ${subtotalField}';
  }

  /// Format total line
  static String _formatTotal(String label, double amount, {bool isFinal = false}) {
    final formattedAmount = _formatCurrency(amount);
    final labelPadding = _maxLineLength - formattedAmount.length;
    
    if (isFinal) {
      return '${label.padRight(labelPadding)}${formattedAmount}';
    }
    
    return '${label.padRight(labelPadding)}${formattedAmount}';
  }
} 