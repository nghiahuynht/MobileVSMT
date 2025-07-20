import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

import '../domain/entities/order/order.dart';
import '../domain/entities/order/order_item.dart';

class SunmiFontSize {
  static const MD = 16;
  static const SM = 12;
  static const LG = 20;
}

class ReceiptPrinterService {
  static final ReceiptPrinterService _instance =
      ReceiptPrinterService._internal();
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

  /// In hóa đơn
  Future<bool> printReceipt(OrderModel order) async {
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
      await SunmiPrinter.printText('HÓA ĐƠN BÁN HÀNG');
      await SunmiPrinter.lineWrap(1);

      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.setFontSize(SunmiFontSize.SM);

      // Thông tin đơn hàng
      await SunmiPrinter.printText('Mã: ${order.code}');
      await SunmiPrinter.printText(
          'Ngày: ${_formatDate(order.orderDate ?? DateTime.now())}');
      await SunmiPrinter.printText(
          'Giờ: ${_formatTime(order.orderDate ?? DateTime.now())}');
      await SunmiPrinter.lineWrap(1);

      // Thông tin khách hàng
      if (order.customerName != null) {
        await SunmiPrinter.printText('Khách hàng: ${order.customerName}');
        if (order.customerCode != null) {
          await SunmiPrinter.printText('Mã KH: ${order.customerCode}');
        }
        if (order.customerGroupName != null) {
          await SunmiPrinter.printText('Nhóm KH: ${order.customerGroupName}');
        }
        await SunmiPrinter.lineWrap(1);
      }

      // Đường kẻ
      await SunmiPrinter.printText('${'─' * 32}');
      await SunmiPrinter.lineWrap(1);

      // Header bảng sản phẩm
      await SunmiPrinter.printText(
          '${'Tên sản phẩm'.padRight(20)} ${'SL'.padLeft(4)} ${'Giá'.padLeft(8)}');
      await SunmiPrinter.printText('${'─' * 32}');

      // Danh sách sản phẩm
      for (OrderItemModel item in order.lstSaleOrderItem) {
        final productName = (item.productName?.length ?? 0) > 18
            ? '${item.productName?.substring(0, 15)}...'
            : item.productName;

        final quantity = item.quantity.toString().padLeft(4);
        final price =
            _formatCurrency(item.priceWithVAT?.toDouble() ?? 0).padLeft(8);

        await SunmiPrinter.printText(
            '${productName?.padRight(20) ?? 0} $quantity $price');
      }

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
      await SunmiPrinter.printText('Đơn hàng: ${order.code}');
      await SunmiPrinter.printText(
          'Ngày: ${_formatDate(order.orderDate ?? DateTime.now())}');

      if (order.customerName != null) {
        await SunmiPrinter.printText('KH: ${order.customerName}');
      }

      await SunmiPrinter.printText(
          'Tổng: ${_formatCurrency(order.totalWithVAT?.toDouble() ?? 0)}');
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
      await SunmiPrinter.printText(
          'Tổng doanh thu: ${_formatCurrency(totalRevenue)}');
      await SunmiPrinter.lineWrap(1);

      // Danh sách đơn hàng
      for (OrderModel order in orders.take(10)) {
        // Chỉ in 10 đơn đầu
        await SunmiPrinter.printText(
            '${order.code}: ${_formatCurrency(order.totalWithVAT?.toDouble() ?? 0)}');
      }

      if (orders.length > 10) {
        await SunmiPrinter.printText(
            '... và ${orders.length - 10} đơn hàng khác');
      }

      await SunmiPrinter.lineWrap(2);

      return true;
    } catch (e) {
      print('Lỗi in báo cáo: $e');
      return false;
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
}
