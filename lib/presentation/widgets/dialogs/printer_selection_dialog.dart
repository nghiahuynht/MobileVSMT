import 'package:flutter/material.dart';
import 'package:trash_pay/constants/colors.dart';
import '../../../constants/font_family.dart';
import '../../../services/bluetooth_printer_service.dart';

class PrinterSelectionDialog extends StatefulWidget {
  const PrinterSelectionDialog({super.key});

  @override
  State<PrinterSelectionDialog> createState() => _PrinterSelectionDialogState();
}

class _PrinterSelectionDialogState extends State<PrinterSelectionDialog> {
  final BluetoothPrinterService _printerService = BluetoothPrinterService();
  List<BluetoothDevice> _availableDevices = [];
  List<BluetoothDevice> _bondedDevices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectionError;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBondedDevices();
  }

  Future<void> _loadBondedDevices() async {
    try {
      final devices = await _printerService.getBondedDevices();
      if (mounted) {
        setState(() {
          _bondedDevices = devices;
        });
      }
    } catch (e) {
      print('Error loading bonded devices: $e');
    }
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
      _connectionError = null;
    });

    try {
      final devices = await _printerService.scanDevices();
      if (mounted) {
        setState(() {
          _availableDevices = devices;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _connectionError = 'Lỗi quét thiết bị: $e';
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _connectionError = null;
    });

    try {
      final success = await _printerService.connectToDevice(device);
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });

        if (success) {
          Navigator.of(context).pop(device);
        } else {
          setState(() {
            _connectionError = 'Không thể kết nối với máy in';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectionError = 'Lỗi kết nối: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.print,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chọn Máy In',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      text: 'Đã Ghép Nối',
                      index: 0,
                      icon: Icons.bluetooth_connected,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      text: 'Quét Thiết Bị',
                      index: 1,
                      icon: Icons.bluetooth_searching,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Error Message
            if (_connectionError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _connectionError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontFamily: FontFamily.productSans,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Content
            Expanded(
              child: _selectedTabIndex == 0 
                ? _buildBondedDevicesTab()
                : _buildScanDevicesTab(),
            ),
            
            // Bottom Actions
            if (_selectedTabIndex == 1)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isScanning || _isConnecting ? null : _scanForDevices,
                      icon: _isScanning 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                      label: Text(
                        _isScanning ? 'Đang quét...' : 'Quét Lại',
                        style: TextStyle(
                          fontFamily: FontFamily.productSans,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String text,
    required int index,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _connectionError = null;
        });
        
        if (index == 1 && _availableDevices.isEmpty) {
          _scanForDevices();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontFamily: FontFamily.productSans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBondedDevicesTab() {
    if (_bondedDevices.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bluetooth_disabled,
        title: 'Không có thiết bị đã ghép nối',
        subtitle: 'Chuyển sang tab "Quét Thiết Bị" để tìm máy in',
      );
    }

    return ListView.builder(
      itemCount: _bondedDevices.length,
      itemBuilder: (context, index) {
        final device = _bondedDevices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildScanDevicesTab() {
    if (_isScanning) {
      return _buildLoadingState();
    }

    if (_availableDevices.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bluetooth_searching,
        title: 'Chưa tìm thấy thiết bị',
        subtitle: 'Nhấn "Quét Lại" để tìm kiếm máy in Bluetooth',
      );
    }

    return ListView.builder(
      itemCount: _availableDevices.length,
      itemBuilder: (context, index) {
        final device = _availableDevices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device) {
    final isConnected = _printerService.connectedDevice?.address == device.address;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected 
            ? AppColors.primary 
            : Colors.grey.withOpacity(0.3),
          width: isConnected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isConnected 
              ? AppColors.primary 
              : Colors.grey[600]
            )?.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isConnected ? Icons.print : Icons.print_outlined,
            color: isConnected 
              ? AppColors.primary 
              : Colors.grey[600],
            size: 24,
          ),
        ),
        title: Text(
          device.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
            fontFamily: FontFamily.productSans,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              device.address,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: FontFamily.productSans,
              ),
            ),
            if (device.isBonded) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 14,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đã ghép nối',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: isConnected
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Đã kết nối',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: FontFamily.productSans,
                ),
              ),
            )
          : _isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : ElevatedButton(
                onPressed: () => _connectToDevice(device),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Kết nối',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang quét thiết bị Bluetooth...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: FontFamily.productSans,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng bật Bluetooth và để máy in ở chế độ ghép nối',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: FontFamily.productSans,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }
} 