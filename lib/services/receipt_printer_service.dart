import 'dart:convert';
import 'dart:io';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:number_to_vietnamese_words/number_to_vietnamese_words.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:trash_pay/presentation/widgets/dialogs/widgets/status_toast.dart';
import 'package:trash_pay/services/user_prefs.dart';
import 'package:trash_pay/utils/extension.dart';

import '../domain/entities/order/order.dart';
import '../domain/entities/order/order_item.dart';

class SunmiFontSize {
  static const MD = 16;
  static const SM = 12;
  static const LG = 20;
}

class ReceiptPrinterService {
  static final ReceiptPrinterService instance =
      ReceiptPrinterService._internal();
  factory ReceiptPrinterService() => instance;
  ReceiptPrinterService._internal();

  final UserPrefs _prefs = UserPrefs.I;

  bool isSunmi = true;

  Future<void> checkSunmiPOS() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        
        // Kiểm tra brand và model để xác định thiết bị Sunmi
        final brand = androidInfo.brand.toLowerCase();
        final model = androidInfo.model.toLowerCase();
        final manufacturer = androidInfo.manufacturer.toLowerCase();
        
        print('Device info: Brand: $brand, Model: $model, Manufacturer: $manufacturer');
        
        // Sunmi POS thường có brand/manufacturer là "sunmi"
        isSunmi = brand.contains('sunmi') || 
                  manufacturer.contains('sunmi') ||
                  model.contains('sunmi');
                  
        print('Device is Sunmi POS: $isSunmi');
      } else {
        // Trên iOS không có thiết bị Sunmi POS
        isSunmi = false;
      }
    } catch (e) {
      print('Error checking device info: $e');
      // Mặc định là false nếu không thể kiểm tra
      isSunmi = false;
    }
  }




  /// Khởi tạo kết nối với máy in
  Future<bool> initializePrinter() async {
    try {
      await checkSunmiPOS();

      if (!isSunmi) {
        final prefs = await SharedPreferences.getInstance();
        final savedDevicesJson =
            prefs.getStringList("saved_bluetooth_devices") ?? [];

        if (savedDevicesJson.isNotEmpty) {
          final _savedDevices = savedDevicesJson.map((deviceJson) {
            final deviceMap = jsonDecode(deviceJson) as Map<String, dynamic>;
            return BluetoothDevice(
              deviceMap['name'] ?? '',
              deviceMap['address'] ?? '',
            );
          }).toList();

          // Mark that AppBloc is initializing printer connection
          await prefs.setInt('app_bloc_printer_init_time', DateTime.now().millisecondsSinceEpoch);
          
          print('AppBloc: Connecting to printer: ${_savedDevices.last.name}');

          BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 5)).then((value) => BluetoothPrintPlus.connect(_savedDevices.last));

          
          // Save the connected device info for ConnectPrinterScreen
          final lastConnectedJson = jsonEncode({
            'name': _savedDevices.last.name,
            'address': _savedDevices.last.address,
          });
          await prefs.setString('last_connected_device', lastConnectedJson);
          
          print('AppBloc: Printer connection initiated successfully');
        } else {
          print('AppBloc: No saved devices found for auto-connect');
        }
      } else {
        print('AppBloc: Device is Sunmi POS, using built-in printer');
      }

      return isSunmi;
    } catch (e) {
      print('AppBloc: Failed to initialize printer: $e');
      // Nếu có lỗi, mặc định là không phải Sunmi
      isSunmi = false;
      return false;
    }
  }

  Future<bool> printReceipt(OrderModel order) async {
    if (isSunmi) {
      return await printReceiptSunmi(order);
    } else {
      return await printReceiptOther(order);
    }
  }


  Future<bool> printReceiptOther(OrderModel order) async {
    try {
      final escCommand = EscCommand();

      final now = DateTime.now();
      final total = order.totalWithVAT?.toInt() ?? 0;
      final totalFormatted = NumberFormat("#,###").format(total);

      final companyName = _prefs.getCompanyName();

      // Clean command buffer và setup
      await escCommand.cleanCommand();
      await escCommand.print(feedLines: 2);
      
      // Header - Company name (Center, Normal)
      await escCommand.text(
        content: (companyName ?? '').removeDiacritics,
        alignment: Alignment.center,
      );
      await escCommand.newline();
      
      // Title (Center, Bold)
      await escCommand.text(
        content: 'BIÊN NHẬN THANH TOÁN'.removeDiacritics,
        alignment: Alignment.center,
        style: EscTextStyle.bold,
        fontSize: EscFontSize.size2,
      );
      await escCommand.newline();
      
      await escCommand.text(
        content: 'DV thu gom, VC rác SH'.removeDiacritics,
        alignment: Alignment.center,
        style: EscTextStyle.bold,
      );
      await escCommand.newline();
      
      // Date time (Center, Normal)
      await escCommand.text(
        content: 'Ngày: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(now)}'.removeDiacritics,
        alignment: Alignment.center,
      );
      await escCommand.newline();
      await escCommand.newline();
      
      // // Separator line
      // await escCommand.text(content: '${'─' * 32}');
      // await escCommand.newline();
      
      // Customer info (Left aligned)
      await escCommand.text(content: 'Mã KH: ${order.customerCode ?? ''}'.removeDiacritics);
      await escCommand.newline();
      await escCommand.text(content: 'Tên KH: ${order.customerName ?? ''}'.removeDiacritics);
      await escCommand.newline();
      await escCommand.text(content: 'Địa chỉ: ${order.customerAddress ?? ''}'.removeDiacritics);
      await escCommand.newline();
      await escCommand.text(content: 'Hình thức TT: ${order.paymentName ?? ''}'.removeDiacritics);
      await escCommand.newline();
      await escCommand.text(content: 'Loại thu: ${order.arrears ?? ''}'.removeDiacritics);
      await escCommand.newline();
      await escCommand.newline();
      
      // Product section separator
      await escCommand.text(content: '${'─' * 16}');
      await escCommand.newline();
      
      // Product header
      await escCommand.text(
        content: '${'Tên sản phẩm'.padRight(20)} ${'Giá'.padLeft(10)}'.removeDiacritics,
        style: EscTextStyle.bold,
      );
      await escCommand.newline();
      await escCommand.text(content: '${'─' * 16}');
      await escCommand.newline();
      
      // Product items
      for (var item in order.lstSaleOrderItem) {
        final productName = (item.productName?.length ?? 0) > 18
            ? '${item.productName?.substring(0, 15)}...'
            : item.productName ?? '';
            
        final totalPrice = (item.priceWithVAT ?? 0).toDouble() * item.quantity;
        final price = _formatCurrency(totalPrice);
        
        await escCommand.text(content: '${productName.padRight(20)} ${price.padLeft(10)}'.removeDiacritics);
        await escCommand.newline();
        
        // Quantity and unit price details
        final quantity = item.quantity;
        final unitPrice = _formatCurrency((item.priceWithVAT ?? 0).toDouble());
        await escCommand.text(content: '  $quantity x $unitPrice'.removeDiacritics);
        await escCommand.newline();
      }
      
      // Final separator
      await escCommand.text(content: '${'─' * 16}');
      await escCommand.newline();
      
      // Total
      await escCommand.text(
        content: 'Tổng tiền: $totalFormatted đ'.removeDiacritics,
        style: EscTextStyle.bold,
      );
      await escCommand.newline();
      
      // Total in words
      await escCommand.text(content: 'Số tiền bằng chữ: ${_convertNumberToWords(total)} đồng'.removeDiacritics);
      await escCommand.newline();
      await escCommand.newline();
      
      // Note
      if (order.note?.isNotEmpty == true) {
        await escCommand.text(content: 'Ghi chú: ${order.note}'.removeDiacritics);
        await escCommand.newline();
      }
      
      // Staff name
      await escCommand.text(content: 'Nhân viên: ${order.saleUserFullName ?? ''}'.removeDiacritics);
      await escCommand.newline();
      await escCommand.text(content: '${'─' * 16}');
      await escCommand.newline();
      await escCommand.newline();
      
      // QR Code
      await escCommand.qrCode(
        content: 'https://mily.vn/ductrong',
        alignment: Alignment.center,
      );
      await escCommand.newline();
      
      // QR instruction
      await escCommand.text(
        content: 'Quý khách quét mã QR hoặc truy cập:'.removeDiacritics,
        alignment: Alignment.center,
      );
      await escCommand.newline();
      await escCommand.text(
        content: 'https://mily.vn/ductrong',
        alignment: Alignment.center,
      );
      await escCommand.newline();
      await escCommand.text(
        content: 'để tra cứu hóa đơn điện tử'.removeDiacritics,
        alignment: Alignment.center,
      );
      await escCommand.newline();
      
      // Feed lines and get command
      await escCommand.print(feedLines: 5);
      final cmd = await escCommand.getCommand();
      
      // Send to printer
      await BluetoothPrintPlus.write(cmd);
      return true;
    } catch (e) {
      XStatusToast('Lỗi in hóa đơn: $e');
      return false;
    }
  }


  Future<bool> printReceiptSunmi(OrderModel order) async {
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
      await SunmiPrinter.printText('Địa chỉ: ${order.customerAddress ?? ''}\n');
      await SunmiPrinter.printText(
          'Hình thức TT: ${order.paymentName ?? ''}\n');
      await SunmiPrinter.printText('Loại thu: ${order.arrears ?? ""}\n');
      
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


      await SunmiPrinter.printText('Nhân viên: ${order.saleUserFullName ?? ''}\n');
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



  /// Format tiền tệ
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
  }

  String _convertNumberToWords(int number) {
    return number.toVietnameseWords();
  }
}
