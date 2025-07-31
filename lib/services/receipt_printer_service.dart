import 'package:intl/intl.dart';
import 'package:number_to_vietnamese_words/number_to_vietnamese_words.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:trash_pay/services/user_prefs.dart';

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

  final UserPrefs _prefs = UserPrefs.I;

  /// Khởi tạo kết nối với máy in
  Future<bool> initializePrinter() async {
    try {
      await SunmiPrinter.bindingPrinter();
      await SunmiPrinter.initPrinter();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.setFontSize(SunmiFontSize.MD);

      return true;
    } catch (e) {
      print('Lỗi khởi tạo máy in: $e');
      return false;
    }
  }

  Future<bool> printReceipt(OrderModel order) async {
    try {
      final now = DateTime.now();
      final total = order.totalWithVAT?.toInt() ?? 0;
      final totalFormatted = NumberFormat("#,###").format(total);

      final companyName = _prefs.getCompanyName();

      final normalCenter = SunmiTextStyle(
            align: SunmiPrintAlign.CENTER,
          );

      final boldCenter = SunmiTextStyle(
            align: SunmiPrintAlign.CENTER,
            bold: true,
          );

      await SunmiPrinter.printText('${companyName ?? ''}\n',
        style: normalCenter,
      );
      await SunmiPrinter.printText('BIÊN NHẬN THANH TOÁN\n', style: boldCenter);
      await SunmiPrinter.printText('DV thu gom, VC rác SH\n', style: boldCenter);
      await SunmiPrinter.printText(
          'Ngày: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(now)}\n', style: normalCenter);

      await SunmiPrinter.line();
      await SunmiPrinter.line();

      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText('Mã KH: ${order.customerCode ?? ''}\n');
      await SunmiPrinter.printText('Tên KH: ${order.customerName ?? ''}\n');
      await SunmiPrinter.printText('Địa chỉ: ${order.taxAddress ?? ''}\n');
      await SunmiPrinter.printText(
          'Hình thức TT: ${order.paymentName ?? ''}\n');
      await SunmiPrinter.printText('Loại thu: ${order.arrears}\n');
      
// Các mặt hàng
      await SunmiPrinter.printText('${'─' * 32}');
      await SunmiPrinter.lineWrap(1);

      // Header bảng sản phẩm
      await SunmiPrinter.printText(
          '${'Tên sản phẩm'.padRight(24)} ${'Giá'.padLeft(6)}');
      await SunmiPrinter.printText('${'─' * 32}');

      // Danh sách sản phẩm
      for (OrderItemModel item in order.lstSaleOrderItem) {
        final productName = (item.productName?.length ?? 0) > 18
            ? '${item.productName?.substring(0, 15)}...'
            : item.productName;

        // final quantity = "${item.quantity} x ${item.priceNoVAT}";

        // final vat = '(VAT: ${item.vat ?? 0}%)';

        final price =
            _formatCurrency( (item.priceWithVAT ?? 0).toDouble() * (item.quantity));

        await SunmiPrinter.printText(
            '${productName?.padRight(24 - productName.length) ?? 0} ${price.padLeft(14)}');

        // await SunmiPrinter.printText(
        //     '${quantity.padRight(24 - quantity.length)} ${vat.padLeft(14)}');


        await SunmiPrinter.printText('${'─' * 32}');
        await SunmiPrinter.lineWrap(1);

      }

      await SunmiPrinter.line();
      await SunmiPrinter.printText('Tổng tiền: $totalFormatted đ\n');

      await SunmiPrinter.printText(
          'Số tiền bằng chữ: ${_convertNumberToWords(total)} đồng\n');


      await SunmiPrinter.printText(
          'Ghi chú: ${order.note ?? ''}\n\n');


      await SunmiPrinter.printText('Nhân viên: ${order.saleUserFullName}\n');
      await SunmiPrinter.line();

      await SunmiPrinter.printQRCode("https://mily.vn/ductrong",
          style: SunmiQrcodeStyle(
            align: SunmiPrintAlign.CENTER,
          ));
      await SunmiPrinter.line();
      await SunmiPrinter.printText('Quý khách quét mã QR hoặc tuy cứu: https://mily.vn/ductrong để tra cứu hoá đơn điện tử\n', style: normalCenter);

      await SunmiPrinter.cutPaper();

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
