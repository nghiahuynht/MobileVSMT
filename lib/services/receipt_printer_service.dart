import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

import '../domain/entities/order/order.dart';
import '../domain/entities/order/order_item.dart';

class ReceiptPrinterService {
  static final ReceiptPrinterService _instance = ReceiptPrinterService._internal();
  factory ReceiptPrinterService() => _instance;
  ReceiptPrinterService._internal();

  bool _isConnected = false;

  /// Khởi tạo kết nối với máy in
  Future<bool> initializePrinter() async {
    try {
      await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.initPrinter();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.setFontSize(SunmiFontSize.MD);
      
      _isConnected = true;
      return true;
    } catch (e) {
      print('Lỗi khởi tạo máy in: $e');
      _isConnected = false;
      return false;
    }
  }

  // /// Kiểm tra trạng thái máy in
  // Future<Map<String, dynamic>> checkPrinterStatus() async {
  //   try {
  //     final isConnected = await SunmiPrinter.isPrinter();
  //     final isPaperReady = await SunmiPrinter.paperStatus();
      
  //     _isConnected = isConnected;
  //     _isPaperReady = isPaperReady == 1;
      
  //     return {
  //       'isConnected': isConnected,
  //       'isPaperReady': isPaperReady == 1,
  //       'paperStatus': _getPaperStatusText(isPaperReady),
  //     };
  //   } catch (e) {
  //     print('Lỗi kiểm tra trạng thái máy in: $e');
  //     return {
  //       'isConnected': false,
  //       'isPaperReady': false,
  //       'paperStatus': 'Không thể kiểm tra',
  //     };
  //   }
  // }

  /// In hóa đơn
  Future<bool> printReceipt(OrderModel order) async {
    try {
      if (!_isConnected) {
        final initialized = await initializePrinter();
        if (!initialized) {
          throw Exception('Không thể kết nối máy in');
        }
      }

      // // Kiểm tra giấy
      // final status = await checkPrinterStatus();
      // if (!status['isPaperReady']) {
      //   throw Exception('Máy in hết giấy hoặc có lỗi: ${status['paperStatus']}');
      // }

      // Bắt đầu in
      await SunmiPrinter.initPrinter();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.setFontSize(SunmiFontSize.LG);
      await SunmiPrinter.printText('TRASHPAY');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.setFontSize(SunmiFontSize.MD);
      await SunmiPrinter.printText('HÓA ĐƠN BÁN HÀNG');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.setFontSize(SunmiFontSize.SM);
      
      // Thông tin đơn hàng
      await SunmiPrinter.printText('Số đơn: ${order.orderNumber}');
      await SunmiPrinter.printText('Ngày: ${_formatDate(order.createdAt)}');
      await SunmiPrinter.printText('Giờ: ${_formatTime(order.createdAt)}');
      await SunmiPrinter.lineWrap(1);
      
      // Thông tin khách hàng
      if (order.customer != null) {
        await SunmiPrinter.printText('Khách hàng: ${order.customer!.name}');
        if (order.customer!.phone != null) {
          await SunmiPrinter.printText('SĐT: ${order.customer!.phone}');
        }
        if (order.customer!.address != null) {
          await SunmiPrinter.printText('Địa chỉ: ${order.customer!.address}');
        }
        await SunmiPrinter.lineWrap(1);
      }
      
      // Đường kẻ
      await SunmiPrinter.printText('${'─' * 32}');
      await SunmiPrinter.lineWrap(1);
      
      // Header bảng sản phẩm
      await SunmiPrinter.printText('${'Tên sản phẩm'.padRight(20)} ${'SL'.padLeft(4)} ${'Giá'.padLeft(8)}');
      await SunmiPrinter.printText('${'─' * 32}');
      
      // Danh sách sản phẩm
      for (OrderItemModel item in order.items) {
        final productName = item.product.name.length > 18 
            ? '${item.product.name.substring(0, 15)}...' 
            : item.product.name;
        
        final quantity = item.quantity.toString().padLeft(4);
        final price = _formatCurrency(item.unitPrice).padLeft(8);
        
        await SunmiPrinter.printText('${productName.padRight(20)} $quantity $price');
        
        // In thông tin chi tiết nếu cần
        if (item.product.description != null && item.product.description!.isNotEmpty) {
          final description = item.product.description!.length > 30 
              ? '${item.product.description!.substring(0, 27)}...' 
              : item.product.description!;
          await SunmiPrinter.printText('  $description');
        }
      }
      
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText('${'─' * 32}');
      
      // Tổng kết
      await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
      await SunmiPrinter.printText('Tổng tiền hàng: ${_formatCurrency(order.subtotal)}');
      
      if (order.discount > 0) {
        await SunmiPrinter.printText('Giảm giá: ${_formatCurrency(order.discount)}');
      }
      
      if (order.tax > 0) {
        await SunmiPrinter.printText('Thuế: ${_formatCurrency(order.tax)}');
      }
      
      await SunmiPrinter.setFontSize(SunmiFontSize.MD);
      await SunmiPrinter.printText('TỔNG CỘNG: ${_formatCurrency(order.total)}');
      await SunmiPrinter.setFontSize(SunmiFontSize.SM);
      
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText('${'─' * 32}');
      
      // Ghi chú
      if (order.notes != null && order.notes!.isNotEmpty) {
        await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
        await SunmiPrinter.printText('Ghi chú: ${order.notes}');
        await SunmiPrinter.lineWrap(1);
      }
      
      // Footer
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText('Cảm ơn quý khách!');
      await SunmiPrinter.printText('Hẹn gặp lại!');
      await SunmiPrinter.lineWrap(3);
      
      return true;
    } catch (e) {
      print('Lỗi in hóa đơn: $e');
      return false;
    }
  }

  /// In hóa đơn đơn giản (cho đơn hàng nhỏ)
  Future<bool> printSimpleReceipt(OrderModel order) async {
    try {
      if (!_isConnected) {
        final initialized = await initializePrinter();
        if (!initialized) {
          throw Exception('Không thể kết nối máy in');
        }
      }

      await SunmiPrinter.initPrinter();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.setFontSize(SunmiFontSize.MD);
      await SunmiPrinter.printText('TRASHPAY');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.setFontSize(SunmiFontSize.SM);
      await SunmiPrinter.printText('Đơn hàng: ${order.orderNumber}');
      await SunmiPrinter.printText('Ngày: ${_formatDate(order.createdAt)}');
      
      if (order.customer != null) {
        await SunmiPrinter.printText('KH: ${order.customer!.name}');
      }
      
      await SunmiPrinter.printText('Tổng: ${_formatCurrency(order.total)}');
      await SunmiPrinter.lineWrap(2);
      
      return true;
    } catch (e) {
      print('Lỗi in hóa đơn đơn giản: $e');
      return false;
    }
  }

  /// In báo cáo doanh thu
  Future<bool> printRevenueReport({
    required DateTime fromDate,
    required DateTime toDate,
    required double totalRevenue,
    required int totalOrders,
    required List<OrderModel> orders,
  }) async {
    try {
      if (!_isConnected) {
        final initialized = await initializePrinter();
        if (!initialized) {
          throw Exception('Không thể kết nối máy in');
        }
      }

      await SunmiPrinter.initPrinter();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.setFontSize(SunmiFontSize.LG);
      await SunmiPrinter.printText('TRASHPAY');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.setFontSize(SunmiFontSize.MD);
      await SunmiPrinter.printText('BÁO CÁO DOANH THU');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.setFontSize(SunmiFontSize.SM);
      
      await SunmiPrinter.printText('Từ ngày: ${_formatDate(fromDate)}');
      await SunmiPrinter.printText('Đến ngày: ${_formatDate(toDate)}');
      await SunmiPrinter.lineWrap(1);
      
      await SunmiPrinter.printText('${'─' * 32}');
      await SunmiPrinter.printText('Tổng đơn hàng: $totalOrders');
      await SunmiPrinter.printText('Tổng doanh thu: ${_formatCurrency(totalRevenue)}');
      await SunmiPrinter.lineWrap(1);
      
      // Danh sách đơn hàng
      for (OrderModel order in orders.take(10)) { // Chỉ in 10 đơn đầu
        await SunmiPrinter.printText('${order.orderNumber}: ${_formatCurrency(order.total)}');
      }
      
      if (orders.length > 10) {
        await SunmiPrinter.printText('... và ${orders.length - 10} đơn hàng khác');
      }
      
      await SunmiPrinter.lineWrap(2);
      
      return true;
    } catch (e) {
      print('Lỗi in báo cáo: $e');
      return false;
    }
  }

  // /// Kiểm tra kết nối máy in
  // Future<bool> isPrinterConnected() async {
  //   try {
  //     return await SunmiPrinter.isPrinter();
  //   } catch (e) {
  //     return false;
  //   }
  // }

  /// Lấy trạng thái giấy
  String _getPaperStatusText(int status) {
    switch (status) {
      case 0:
        return 'Giấy bình thường';
      case 1:
        return 'Hết giấy';
      case 2:
        return 'Giấy sắp hết';
      case 3:
        return 'Lỗi giấy';
      case 4:
        return 'Không có giấy';
      case 5:
        return 'Giấy bị kẹt';
      default:
        return 'Trạng thái không xác định';
    }
  }

  /// Format ngày tháng
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format thời gian
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format tiền tệ
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
  }

  // /// Đóng kết nối máy in
  // Future<void> disconnect() async {
  //   try {
  //     await SunmiPrinter.disconnect();
  //     _isConnected = false;
  //   } catch (e) {
  //     print('Lỗi đóng kết nối máy in: $e');
  //   }
  // }
}

class SunmiFontSize {
  static const MD = 16;
  static const SM = 12;
  static const LG = 20;
} 