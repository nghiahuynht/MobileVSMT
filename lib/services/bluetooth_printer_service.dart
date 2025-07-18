import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDevice {
  final String name;
  final String address;
  final bool isBonded;

  BluetoothDevice({
    required this.name,
    required this.address,
    required this.isBonded,
  });

  @override
  String toString() => 'BluetoothDevice{name: $name, address: $address}';
}

class BluetoothPrinterService {
  static final BluetoothPrinterService _instance = BluetoothPrinterService._internal();
  factory BluetoothPrinterService() => _instance;
  BluetoothPrinterService._internal();

  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;
  
  // Check if currently connected to a printer
  bool get isConnected => _isConnected;
  
  // Get connected device info
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Request necessary permissions for Bluetooth
  Future<bool> requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      bool allGranted = statuses.values.every(
        (status) => status == PermissionStatus.granted,
      );

      return allGranted;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Get mock devices for demonstration (replace with actual Bluetooth scanning)
  Future<List<BluetoothDevice>> scanDevices() async {
    try {
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception('Bluetooth permissions not granted');
      }

      // Simulate scanning delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock devices for demonstration
      // In real implementation, you would use flutter_bluetooth_serial or similar
      return [
        BluetoothDevice(name: 'Thermal Printer 1', address: '00:11:22:33:44:55', isBonded: true),
        BluetoothDevice(name: 'ESC/POS Printer', address: '00:11:22:33:44:56', isBonded: false),
        BluetoothDevice(name: 'Receipt Printer', address: '00:11:22:33:44:57', isBonded: true),
        BluetoothDevice(name: 'Mobile Printer', address: '00:11:22:33:44:58', isBonded: true),
      ];
    } catch (e) {
      print('Error scanning devices: $e');
      rethrow;
    }
  }

  /// Connect to a Bluetooth printer (mock implementation)
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception('Bluetooth permissions not granted');
      }

      // Mock connection for demonstration
      // In real implementation, you would establish actual Bluetooth connection
      await Future.delayed(const Duration(seconds: 2)); // Simulate connection time
      
      _connectedDevice = device;
      _isConnected = true;
      
      if (kDebugMode) {
        print('Connected to printer: ${device.name}');
      }
      
      return true;
    } catch (e) {
      print('Error connecting to printer: $e');
      _connectedDevice = null;
      _isConnected = false;
      return false;
    }
  }

  /// Disconnect from current printer
  Future<void> disconnect() async {
    try {
      _connectedDevice = null;
      _isConnected = false;
      
      if (kDebugMode) {
        print('Disconnected from printer');
      }
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  /// Print receipt (simplified implementation)
  Future<bool> printReceipt({
    required String companyName,
    required String address,
    required String phone,
    required String orderNumber,
    required DateTime orderDate,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    String? notes,
  }) async {
    try {
      if (!isConnected) {
        throw Exception('No printer connected');
      }

      // Simulate printing delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (kDebugMode) {
        print('=== RECEIPT PREVIEW ===');
        print('$companyName');
        print('$address');
        print('Tel: $phone');
        print('------------------------');
        print('HÓA ĐƠN BÁN HÀNG');
        print('------------------------');
        print('Số HĐ: $orderNumber');
        print('Ngày: ${_formatDateTime(orderDate)}');
        print('KH: $customerName');
        print('------------------------');
        print('Sản phẩm       SL  Giá    Thành tiền');
        print('------------------------');
        
        for (var item in items) {
          String name = (item['name']?.toString() ?? '').length > 15 
              ? '${(item['name']?.toString() ?? '').substring(0, 12)}...' 
              : (item['name']?.toString() ?? '');
          String qty = '${item['quantity']}'.padLeft(2);
          String price = _formatCurrency(item['unitPrice']?.toDouble() ?? 0);
          String subtotalStr = _formatCurrency(item['subtotal']?.toDouble() ?? 0);
          print('$name $qty $price $subtotalStr');
        }
        
        print('------------------------');
        print('Tạm tính: ${_formatCurrency(subtotal)}');
        if (discount > 0) print('Giảm giá: -${_formatCurrency(discount)}');
        if (tax > 0) print('Thuế: ${_formatCurrency(tax)}');
        print('========================');
        print('TỔNG CỘNG: ${_formatCurrency(total)}');
        print('========================');
        if (notes != null && notes.isNotEmpty) {
          print('Ghi chú: $notes');
        }
        print('Cảm ơn quý khách!');
        print('Hẹn gặp lại!');
        print('======================');
      }
      
      return true;
    } catch (e) {
      print('Error printing receipt: $e');
      return false;
    }
  }

  /// Format currency for display
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Check if Bluetooth is enabled (mock implementation)
  Future<bool> isBluetoothEnabled() async {
    try {
      // Mock implementation - always return true for demo
      return true;
    } catch (e) {
      print('Error checking Bluetooth status: $e');
      return false;
    }
  }

  /// Get list of bonded/paired printers (mock implementation)
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception('Bluetooth permissions not granted');
      }

      // Mock bonded devices
      return [
        BluetoothDevice(name: 'My Thermal Printer', address: '00:11:22:33:44:55', isBonded: true),
        BluetoothDevice(name: 'Office Printer', address: '00:11:22:33:44:58', isBonded: true),
      ];
    } catch (e) {
      print('Error getting bonded devices: $e');
      return [];
    }
  }
} 