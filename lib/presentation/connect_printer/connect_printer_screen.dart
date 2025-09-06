import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';
import 'package:trash_pay/constants/colors.dart';

class ConnectPrinterScreen extends StatefulWidget {
  const ConnectPrinterScreen({super.key});

  @override
  State<ConnectPrinterScreen> createState() => _ConnectPrinterScreenState();
}

class _ConnectPrinterScreenState extends State<ConnectPrinterScreen> 
    with WidgetsBindingObserver {
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? _connectingDevice;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<BlueState> _blueStateSubscription;
  late StreamSubscription<ConnectState> _connectStateSubscription;
  late StreamSubscription<Uint8List> _receivedDataSubscription;
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;
  List<BluetoothDevice> _scanResults = [];
  List<BluetoothDevice> _savedDevices = [];
  bool _isConnecting = false;
  bool _isAutoConnecting = false;
  bool _isLoadingSavedDevices = true;
  String? _errorMessage;
  static const String _savedDevicesKey = 'saved_bluetooth_devices';
  static const String _lastConnectedDeviceKey = 'last_connected_device';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initBluetoothPrintPlusListen();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for Bluetooth and AppBloc to be ready
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Load saved devices first
    await _loadSavedDevices();
    
    // Check current connection status (including AppBloc connections)
    await _checkCurrentConnection();
    
    // Then attempt auto connect after a short delay if not connected
    if (_connectedDevice == null) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _attemptAutoConnect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isScanningSubscription.cancel();
    _blueStateSubscription.cancel();
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('App resumed, checking connection status');
      // Add delay to ensure Bluetooth is ready
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _loadSavedDevices();
          _checkCurrentConnection();
        }
      });
    } else if (state == AppLifecycleState.paused) {
      print('App paused');
    } else if (state == AppLifecycleState.inactive) {
      print('App inactive');
    } else if (state == AppLifecycleState.detached) {
      print('App detached');
    }
  }

  Future<void> initBluetoothPrintPlusListen() async {
    /// listen scanResults
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((event) {
      if (mounted) {
        setState(() {
          _scanResults = event;
        });
      }
    });

    /// listen isScanning
    _isScanningSubscription = BluetoothPrintPlus.isScanning.listen((event) {
      print('********** isScanning: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen blue state
    _blueStateSubscription = BluetoothPrintPlus.blueState.listen((event) {
      print('********** blueState change: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen connect state
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((event) {
      print('********** connectState change: $event **********');
      switch (event) {
        case ConnectState.connected:
          if (mounted) {
            setState(() {
              _connectedDevice = _connectingDevice;
              _connectingDevice = null;
              _isConnecting = false;
              _isAutoConnecting = false;
              _errorMessage = null;
            });
            if (_connectedDevice != null) {
              _saveConnectedDevice(_connectedDevice!);
              if (!_isAutoConnecting) {
                _showSuccessMessage('Kết nối máy in thành công!');
              }
            }
          }
          break;
        case ConnectState.disconnected:
          if (mounted) {
            setState(() {
              _connectedDevice = null;
              _connectingDevice = null;
              _isConnecting = false;
              _isAutoConnecting = false;
            });
            _clearLastConnectedDevice();
          }
          break;
      }
    });

    /// listen received data
    _receivedDataSubscription = BluetoothPrintPlus.receivedData.listen((data) {
      print('********** received data: $data **********');

      /// do something...
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Professional Header
            ProfessionalHeaders.detail(
              title: 'Kết nối máy in',
              subtitle: 'Quản lý kết nối thiết bị in Bluetooth',
              // actionWidget: Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: AppColors.primary.withOpacity(0.2),
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(
              //       color: AppColors.primary.withOpacity(0.3),
              //       width: 1,
              //     ),
              //   ),
              //   child: Icon(
              //     Icons.print,
              //     size: 20,
              //     color: Colors.white,
              //   ),
              // ),
            ),
            
            // Content Area
            Expanded(
              child: SafeArea(
                top: false,
                child: BluetoothPrintPlus.isBlueOn
                ? Column(
                    children: [
                  // Auto connecting indicator
                  if (_isAutoConnecting) _buildAutoConnectingIndicator(),
                  
                  // Connected device section
                  if (_connectedDevice != null) _buildConnectedDeviceCard(),
                  
                  // Error message
                  if (_errorMessage != null) _buildErrorMessage(),
                  
                  // Saved devices section
                  // if ((_savedDevices.isNotEmpty || _isLoadingSavedDevices) && _connectedDevice == null) 
                  //   _buildSavedDevicesSection(),
                  
                  // Available devices header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.bluetooth_searching, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Thiết bị có sẵn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        // const Spacer(),
                        // if (BluetoothPrintPlus.isScanningNow)
                        //   const SizedBox(
                        //     width: 20,
                        //     height: 20,  
                        //     child: CircularProgressIndicator(strokeWidth: 2),
                        //   ),
                      ],
                    ),
                  ),
                  
                  // Device list
                  Expanded(
                    child: _scanResults.isEmpty && !BluetoothPrintPlus.isScanningNow
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _scanResults.length,
                            itemBuilder: (context, index) {
                              final device = _scanResults[index];
                              return _buildDeviceCard(device);
                            },
                          ),
                  ),
                    ],
                  )
                : _buildBluetoothOffWidget(),
              ),
            ),
          ],
        ),
        floatingActionButton: BluetoothPrintPlus.isBlueOn ? _buildScanButton() : null,
    );
  }

  Widget _buildAutoConnectingIndicator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang tự động kết nối...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  'Đang kết nối với thiết bị đã lưu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedDevicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
            children: [
              Icon(Icons.bookmark, color: Colors.purple[600]),
              const SizedBox(width: 8),
              Text(
                'Thiết bị đã lưu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              if (_isLoadingSavedDevices)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: _loadSavedDevices,
                  icon: Icon(Icons.refresh, color: Colors.purple[600]),
                  tooltip: 'Tải lại thiết bị đã lưu',
                ),
            ],
          ),
        ),
        Container(
          height: 120,
          child: _isLoadingSavedDevices
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _savedDevices.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Chưa có thiết bị nào được lưu',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _savedDevices.length,
                      itemBuilder: (context, index) {
                        final device = _savedDevices[index];
                        return _buildSavedDeviceCard(device);
                      },
                    ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSavedDeviceCard(BluetoothDevice device) {
    final isConnecting = _connectingDevice?.address == device.address && _isConnecting;
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bookmark, color: Colors.purple[600], size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    device.name.isNotEmpty ? device.name : 'Thiết bị không tên',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              device.address,
              style: TextStyle(
                fontSize: 10,
                color: Colors.purple[600],
              ),
            ),
            const Spacer(),
            Row(
                                children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isConnecting ? null : () => _connectToDevice(device),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: isConnecting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Kết nối'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeSavedDevice(device),
                  icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDeviceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.print, color: Colors.green[700], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã kết nối',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _connectedDevice!.name.isNotEmpty 
                      ? _connectedDevice!.name 
                      : 'Thiết bị không tên',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _connectedDevice!.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _disconnectDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              foregroundColor: Colors.red[700],
              elevation: 0,
            ),
            child: const Text('Ngắt kết nối'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: Icon(Icons.close, color: Colors.red[700], size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy thiết bị nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút quét để tìm kiếm máy in',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device) {
    final isConnecting = _connectingDevice?.address == device.address && _isConnecting;
    final isConnected = _connectedDevice?.address == device.address;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected 
              ? Colors.green[300]! 
              : Colors.grey[300]!,
          width: isConnected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isConnected 
                    ? Colors.green[100] 
                    : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.print,
                color: isConnected 
                    ? Colors.green[700] 
                    : Colors.blue[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                  Text(
                    device.name.isNotEmpty 
                        ? device.name 
                        : 'Thiết bị không tên',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                                      Text(
                                        device.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isConnected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Đã kết nối',
                                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isConnecting)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (isConnected)
              Icon(Icons.check_circle, color: Colors.green[600], size: 24)
            else
              ElevatedButton(
                onPressed: () => _connectToDevice(device),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Kết nối'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothOffWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bluetooth đã tắt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng bật Bluetooth để kết nối máy in',
      style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
      textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Open Bluetooth settings
              setState(() {});
            },
            icon: const Icon(Icons.settings),
            label: const Text('Mở cài đặt Bluetooth'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    if (BluetoothPrintPlus.isScanningNow) {
      return FloatingActionButton.extended(
        onPressed: _stopScanning,
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.stop),
        label: const Text('Dừng quét'),
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: _startScanning,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.bluetooth_searching),
        label: const Text('Quét thiết bị'),
      );
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      setState(() {
        _connectingDevice = device;
        _isConnecting = true;
        _errorMessage = null;
      });

      await BluetoothPrintPlus.connect(device);
    } catch (e) {
      setState(() {
        _connectingDevice = null;
        _isConnecting = false;
        _errorMessage = 'Không thể kết nối với thiết bị: ${e.toString()}';
      });
    }
  }



  Future<void> _disconnectDevice() async {
    try {
      await BluetoothPrintPlus.disconnect();
      setState(() {
        _connectedDevice = null;
      });
      _showSuccessMessage('Đã ngắt kết nối máy in');
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể ngắt kết nối: ${e.toString()}';
      });
    }
  }

  Future<void> _startScanning() async {
    try {
      setState(() {
        _errorMessage = null;
      });
      await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi quét thiết bị: ${e.toString()}';
      });
    }
  }

  Future<void> _stopScanning() async {
    try {
      BluetoothPrintPlus.stopScan();
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi dừng quét: ${e.toString()}';
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // SharedPreferences methods
  Future<void> _loadSavedDevices() async {
    try {
      setState(() {
        _isLoadingSavedDevices = true;
      });
      
      final prefs = await SharedPreferences.getInstance();
      final savedDevicesJson = prefs.getStringList(_savedDevicesKey) ?? [];
      
      if (mounted) {
        setState(() {
          _savedDevices = savedDevicesJson.map((deviceJson) {
            final deviceMap = jsonDecode(deviceJson) as Map<String, dynamic>;
            return BluetoothDevice(
              deviceMap['name'] ?? '',
              deviceMap['address'] ?? '',
            );
          }).toList();
          _isLoadingSavedDevices = false;
        });
      }
      
      print('Loaded ${_savedDevices.length} saved devices');
    } catch (e) {
      print('Error loading saved devices: $e');
      if (mounted) {
        setState(() {
          _isLoadingSavedDevices = false;
          _errorMessage = 'Lỗi khi tải thiết bị đã lưu: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _saveConnectedDevice(BluetoothDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save to saved devices list if not already saved
      final existingIndex = _savedDevices.indexWhere(
        (d) => d.address == device.address,
      );
      
      if (existingIndex == -1) {
        _savedDevices.add(device);
        final savedDevicesJson = _savedDevices.map((d) {
          return jsonEncode({
            'name': d.name,
            'address': d.address,
          });
        }).toList();
        
        await prefs.setStringList(_savedDevicesKey, savedDevicesJson);
        
        // Reload saved devices to update UI
        await _loadSavedDevices();
      }
      
      // Save as last connected device
      final lastConnectedJson = jsonEncode({
        'name': device.name,
        'address': device.address,
      });
      await prefs.setString(_lastConnectedDeviceKey, lastConnectedJson);
    } catch (e) {
      print('Error saving device: $e');
    }
  }

  Future<void> _removeSavedDevice(BluetoothDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _savedDevices.removeWhere((d) => d.address == device.address);
      });
      
      final savedDevicesJson = _savedDevices.map((d) {
        return jsonEncode({
          'name': d.name,
          'address': d.address,
        });
      }).toList();
      
      await prefs.setStringList(_savedDevicesKey, savedDevicesJson);
      
      // If this was the last connected device, remove it too
      final lastConnectedJson = prefs.getString(_lastConnectedDeviceKey);
      if (lastConnectedJson != null) {
        final lastConnected = jsonDecode(lastConnectedJson);
        if (lastConnected['address'] == device.address) {
          await prefs.remove(_lastConnectedDeviceKey);
        }
      }
      
      // Reload saved devices to update UI
      await _loadSavedDevices();
      
      _showSuccessMessage('Đã xóa thiết bị khỏi danh sách đã lưu');
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi xóa thiết bị: ${e.toString()}';
      });
    }
  }

  Future<void> _checkCurrentConnection() async {
    try {
      if (!BluetoothPrintPlus.isBlueOn) {
        print('Bluetooth is off, cannot check connection');
        return;
      }
      
      print('Checking current connection status...');
      
      // First check if already connected via BluetoothPrintPlus
      try {
        final currentState = await BluetoothPrintPlus.connectState.first
            .timeout(const Duration(seconds: 3));
        
        print('Current connect state: $currentState');
        
        if (currentState == ConnectState.connected) {
          print('Device is currently connected via BluetoothPrintPlus');
          // Get the connected device from saved preferences
          await _restoreConnectedDeviceFromPrefs();
          return;
        }
      } catch (e) {
        print('Error getting connect state, checking preferences: $e');
      }
      
      // If not connected via BluetoothPrintPlus, check saved preferences
      await _restoreConnectedDeviceFromPrefs();
      
    } catch (e) {
      print('Error checking current connection: $e');
    }
  }
  
  Future<void> _restoreConnectedDeviceFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastConnectedJson = prefs.getString(_lastConnectedDeviceKey);
      
      if (lastConnectedJson != null) {
        final deviceMap = jsonDecode(lastConnectedJson) as Map<String, dynamic>;
        final lastDevice = BluetoothDevice(
          deviceMap['name'] ?? '',
          deviceMap['address'] ?? '',
        );
        
        print('Found last connected device: ${lastDevice.name} (${lastDevice.address})');
        
        // Check if this device was connected by AppBloc (via ReceiptPrinterService)
        final wasConnectedByAppBloc = await _checkIfConnectedByAppBloc();
        
        if (wasConnectedByAppBloc) {
          print('Device was connected by AppBloc, restoring UI');
          _restoreConnectionUI(lastDevice);
        } else {
          // Try to validate actual connection
          await _validateConnection(lastDevice);
        }
      } else {
        print('No last connected device found');
      }
    } catch (e) {
      print('Error restoring device from preferences: $e');
    }
  }
  
  Future<bool> _checkIfConnectedByAppBloc() async {
    try {
      // Check if ReceiptPrinterService was recently initialized
      // This is a simple check - you might want to implement a more sophisticated mechanism
      final prefs = await SharedPreferences.getInstance();
      final appBlocInitTime = prefs.getInt('app_bloc_printer_init_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      
      // If AppBloc initialized printer within last 30 seconds, assume it connected
      final timeDiff = currentTime - appBlocInitTime;
      print('Time since AppBloc printer init: ${timeDiff}ms');
      
      return timeDiff < 30000; // 30 seconds
    } catch (e) {
      print('Error checking AppBloc connection: $e');
      return false;
    }
  }
  
  Future<void> _validateConnection(BluetoothDevice device) async {
    try {
      print('Validating connection to: ${device.name}');
      
      // Restore UI state immediately for better UX
      _restoreConnectionUI(device);
      
      // You can add additional validation here if needed
      // For example, try to send a test command to the printer
      
    } catch (e) {
      print('Connection validation failed: $e');
      // Clear connection state if validation fails
      await _clearLastConnectedDevice();
      if (mounted) {
        setState(() {
          _connectedDevice = null;
          _errorMessage = 'Mất kết nối với thiết bị';
        });
      }
    }
  }
  
  void _restoreConnectionUI(BluetoothDevice device) {
    if (mounted) {
      setState(() {
        _connectedDevice = device;
        _isConnecting = false;
        _isAutoConnecting = false;
        _errorMessage = null;
      });
      print('Restored connection UI for: ${device.name} (${device.address})');
    }
  }

  Future<void> _attemptAutoConnect() async {
    try {
      // Wait for Bluetooth to be ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!BluetoothPrintPlus.isBlueOn) {
        print('Bluetooth is off, cannot auto-connect');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final lastConnectedJson = prefs.getString(_lastConnectedDeviceKey);
      
      if (lastConnectedJson != null) {
        final deviceMap = jsonDecode(lastConnectedJson) as Map<String, dynamic>;
        // Convert to BluetoothDevice for connecting
        final lastDevice = BluetoothDevice(
          deviceMap['name'] ?? '',
          deviceMap['address'] ?? '',
        );
        
        if (mounted) {
          setState(() {
            _isAutoConnecting = true;
            _connectingDevice = lastDevice;
          });
        }
        
        print('Attempting auto-connect to: ${lastDevice.name} (${lastDevice.address})');
        
        // Try to connect
        try {
          await BluetoothPrintPlus.connect(lastDevice);
        } catch (connectError) {
          print('Auto-connect failed: $connectError');
          if (mounted) {
            setState(() {
              _isAutoConnecting = false;
              _connectingDevice = null;
              _errorMessage = 'Không thể kết nối tự động với thiết bị';
            });
          }
          return;
        }
        
        // Set a timeout for auto-connect
        Timer(const Duration(seconds: 15), () {
          if (_isAutoConnecting && mounted) {
            setState(() {
              _isAutoConnecting = false;
              _connectingDevice = null;
            });
            print('Auto-connect timeout');
          }
        });
      } else {
        print('No device to auto-connect to');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAutoConnecting = false;
          _connectingDevice = null;
        });
      }
      print('Auto-connect failed: $e');
    }
  }

  Future<void> _clearLastConnectedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastConnectedDeviceKey);
      print('Cleared last connected device');
    } catch (e) {
      print('Error clearing last connected device: $e');
    }
  }
}
