import 'package:intl/intl.dart';
import 'package:number_to_vietnamese_words/number_to_vietnamese_words.dart';
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

  Future<bool> printReceipt(OrderModel order) async {
    try {
      final now = DateTime.now();
      final total = order.totalWithVAT?.toInt() ?? 0;
      final totalFormatted = NumberFormat("#,###").format(total);

      await SunmiPrinter.initPrinter();
      await SunmiPrinter.startTransactionPrint(true);

      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText('BAN QUẢN LÝ VÀ CTCC HUYỆN ĐỨC TRỌNG\n');
      await SunmiPrinter.printText('BIÊN NHẬN THANH TOÁN\n');
      await SunmiPrinter.printText('DV thu gom, VC rác SH\n');
      await SunmiPrinter.printText(
          'Ngày: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(now)}\n');

      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText('Mã KH: ${order.customerCode ?? ''}\n');
      await SunmiPrinter.printText('Tên KH: ${order.customerName ?? ''}\n');
      await SunmiPrinter.printText('Địa chỉ: ${order.taxAddress ?? ''}\n');
      await SunmiPrinter.printText(
          'Hình thức TT: ${order.paymentName ?? ''}\n');
// Các mặt hàng
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

      await SunmiPrinter.line();
      await SunmiPrinter.printText('Tổng tiền: $totalFormatted đ\n');

      await SunmiPrinter.printText(
          'Số tiền bằng chữ: ${_convertNumberToWords(total)} đồng\n');


      await SunmiPrinter.printText(
          'Ghi chú: ${order.note}\n\n');


      await SunmiPrinter.printText('Nhân viên: ${order.saleUserFullName}\n');

      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printQRCode("https://mily.vn/ductrong");
      await SunmiPrinter.printText('Mã KH: ${order.customerCode}\n');
      await SunmiPrinter.printText('Loại thu: ${order.arrears}\n');
      await SunmiPrinter.printText('Quý khách quét mã QR hoặc tuy cứu: https://mily.vn/ductrong để tra cứu hoá đơn điện tử\n');

      await SunmiPrinter.line();
      await SunmiPrinter.cut();

      return true;
    } catch (e) {
      print('Lỗi in hóa đơn: $e');
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

  String _convertNumberToWords(int number) {
    return number.toVietnameseWords();
  }
}
