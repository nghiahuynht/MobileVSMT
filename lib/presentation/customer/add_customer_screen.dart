import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/presentation/customer/logics/customer_bloc.dart';
import 'package:trash_pay/presentation/customer/logics/customer_events.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';
import 'package:trash_pay/constants/font_family.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _customerGroupController = TextEditingController();

  List<Ward> _wards = [];
  List<Group> _groups = [];
  List<Area> _areas = [];

  Ward? _selectedWard;
  Group? _selectedGroup;
  Area? _selectedArea;
  bool _isLoadingWards = false;
  bool _isLoadingGroups = false;
  bool _isLoadingAreas = false;

  @override
  void initState() {
    super.initState();
    _loadWards();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadWards() async {
    setState(() {
      _isLoadingWards = true;
    });

    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      setState(() {
        _wards = [
          const Ward(id: 1, code: 'PX001', name: 'Phường 1', description: 'Phường 1 - Quận 1'),
          const Ward(id: 2, code: 'PX002', name: 'Phường 2', description: 'Phường 2 - Quận 1'),
          const Ward(id: 3, code: 'PX003', name: 'Phường 3', description: 'Phường 3 - Quận 1'),
          const Ward(id: 4, code: 'PX004', name: 'Phường 4', description: 'Phường 4 - Quận 1'),
          const Ward(id: 5, code: 'PX005', name: 'Phường 5', description: 'Phường 5 - Quận 1'),
        ];
        _isLoadingWards = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWards = false;
      });
      _showErrorSnackBar('Không thể tải danh sách phường xã');
    }
  }

  Future<void> _loadGroups(int? wardId) async {
    setState(() {
      _isLoadingGroups = true;
      _groups = [];
      _selectedGroup = null;
    });

    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
      
      final allGroups = [
        const Group(id: 1, code: 'TO001', name: 'Tổ 1', description: 'Tổ 1 - Phường 1', wardId: 1),
        const Group(id: 2, code: 'TO002', name: 'Tổ 2', description: 'Tổ 2 - Phường 1', wardId: 1),
        const Group(id: 3, code: 'TO003', name: 'Tổ 3', description: 'Tổ 3 - Phường 1', wardId: 1),
        const Group(id: 4, code: 'TO004', name: 'Tổ 1', description: 'Tổ 1 - Phường 2', wardId: 2),
        const Group(id: 5, code: 'TO005', name: 'Tổ 2', description: 'Tổ 2 - Phường 2', wardId: 2),
        const Group(id: 6, code: 'TO006', name: 'Tổ 1', description: 'Tổ 1 - Phường 3', wardId: 3),
        const Group(id: 7, code: 'TO007', name: 'Tổ 2', description: 'Tổ 2 - Phường 3', wardId: 3),
        const Group(id: 8, code: 'TO008', name: 'Tổ 1', description: 'Tổ 1 - Phường 4', wardId: 4),
        const Group(id: 9, code: 'TO009', name: 'Tổ 1', description: 'Tổ 1 - Phường 5', wardId: 5),
      ];

      setState(() {
        _groups = wardId != null 
            ? allGroups.where((group) => group.wardId == wardId).toList()
            : allGroups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGroups = false;
      });
      _showErrorSnackBar('Không thể tải danh sách tổ');
    }
  }

  Future<void> _loadAreas(int? groupId) async {
    setState(() {
      _isLoadingAreas = true;
      _areas = [];
      _selectedArea = null;
    });

    try {
      // TODO: Replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
      
      final allAreas = [
        const Area(id: 1, code: 'KH001', name: 'Khu A', description: 'Khu A - Tổ 1', groupId: 1),
        const Area(id: 2, code: 'KH002', name: 'Khu B', description: 'Khu B - Tổ 1', groupId: 1),
        const Area(id: 3, code: 'KH003', name: 'Khu C', description: 'Khu C - Tổ 1', groupId: 1),
        const Area(id: 4, code: 'KH004', name: 'Khu A', description: 'Khu A - Tổ 2', groupId: 2),
        const Area(id: 5, code: 'KH005', name: 'Khu B', description: 'Khu B - Tổ 2', groupId: 2),
        const Area(id: 6, code: 'KH006', name: 'Khu A', description: 'Khu A - Tổ 3', groupId: 3),
        const Area(id: 7, code: 'KH007', name: 'Khu A', description: 'Khu A - Tổ 1 Phường 2', groupId: 4),
        const Area(id: 8, code: 'KH008', name: 'Khu B', description: 'Khu B - Tổ 1 Phường 2', groupId: 4),
        const Area(id: 9, code: 'KH009', name: 'Khu A', description: 'Khu A - Tổ 2 Phường 2', groupId: 5),
        const Area(id: 10, code: 'KH010', name: 'Khu A', description: 'Khu A - Tổ 1 Phường 3', groupId: 6),
        const Area(id: 11, code: 'KH011', name: 'Khu A', description: 'Khu A - Tổ 1 Phường 4', groupId: 8),
        const Area(id: 12, code: 'KH012', name: 'Khu A', description: 'Khu A - Tổ 1 Phường 5', groupId: 9),
      ];

      setState(() {
        _areas = groupId != null 
            ? allAreas.where((area) => area.groupId == groupId).toList()
            : allAreas;
        _isLoadingAreas = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAreas = false;
      });
      _showErrorSnackBar('Không thể tải danh sách khu');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final customerData = CustomerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        wardId: _selectedWard?.id,
        wardName: _selectedWard?.name,
        groupId: _selectedGroup?.id,
        groupName: _selectedGroup?.name,
        areaId: _selectedArea?.id,
        areaName: _selectedArea?.name,
        customerGroup: _customerGroupController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        createdAt: DateTime.now(),
      );

      context.read<CustomerBloc>().add(AddCustomerEvent(customerData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerBloc(),
      child: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF059669),
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          }
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8F9FA),
                  Color(0xFFE9ECEF),
                ],
              ),
            ),
            child: Column(
              children: [
                // Professional Header
                ProfessionalHeaders.detail(
                  title: 'Thêm Khách Hàng',
                  subtitle: 'Nhập thông tin khách hàng mới',
                  onBackPressed: () => Navigator.of(context).pop(),
                ),
                
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer Name
                          _buildTextField(
                            controller: _nameController,
                            label: 'Tên khách hàng',
                            hint: 'Nhập tên khách hàng',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên khách hàng';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Phone Number
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Số điện thoại',
                            hint: 'Nhập số điện thoại',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Ward Selection
                          _buildDropdownField<Ward>(
                            label: 'Phường xã',
                            hint: 'Chọn phường xã',
                            icon: Icons.location_city_outlined,
                            value: _selectedWard,
                            items: _wards,
                            isLoading: _isLoadingWards,
                            onChanged: (Ward? ward) {
                              setState(() {
                                _selectedWard = ward;
                                _selectedGroup = null;
                                _selectedArea = null;
                              });
                              if (ward != null) {
                                _loadGroups(ward.id);
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn phường xã';
                              }
                              return null;
                            },
                            itemBuilder: (Ward ward) => ward.name,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Address
                          _buildTextField(
                            controller: _addressController,
                            label: 'Địa chỉ',
                            hint: 'Nhập địa chỉ chi tiết',
                            icon: Icons.home_outlined,
                            maxLines: 3,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Group Selection
                          _buildDropdownField<Group>(
                            label: 'Tổ',
                            hint: 'Chọn tổ',
                            icon: Icons.group_outlined,
                            value: _selectedGroup,
                            items: _groups,
                            isLoading: _isLoadingGroups,
                            onChanged: (Group? group) {
                              setState(() {
                                _selectedGroup = group;
                                _selectedArea = null;
                              });
                              if (group != null) {
                                _loadAreas(group.id);
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn tổ';
                              }
                              return null;
                            },
                            itemBuilder: (Group group) => group.name,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Area Selection
                          _buildDropdownField<Area>(
                            label: 'Khu',
                            hint: 'Chọn khu',
                            icon: Icons.map_outlined,
                            value: _selectedArea,
                            items: _areas,
                            isLoading: _isLoadingAreas,
                            onChanged: (Area? area) {
                              setState(() {
                                _selectedArea = area;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn khu';
                              }
                              return null;
                            },
                            itemBuilder: (Area area) => area.name,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Customer Group
                          _buildTextField(
                            controller: _customerGroupController,
                            label: 'Nhóm khách hàng',
                            hint: 'Nhập nhóm khách hàng',
                            icon: Icons.category_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập nhóm khách hàng';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Price
                          _buildTextField(
                            controller: _priceController,
                            label: 'Giá tiền',
                            hint: 'Nhập giá tiền dịch vụ',
                            icon: Icons.attach_money_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập giá tiền';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Giá tiền phải lớn hơn 0';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.save_outlined,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Lưu Khách Hàng',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: FontFamily.productSans,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: FontFamily.productSans,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 16,
              fontFamily: FontFamily.productSans,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF059669),
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: FontFamily.productSans,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<T> items,
    required bool isLoading,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    String Function(T)? itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
            fontFamily: FontFamily.productSans,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: isLoading ? 'Đang tải...' : hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 16,
              fontFamily: FontFamily.productSans,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF059669),
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          items: isLoading
              ? []
              : items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      itemBuilder != null ? itemBuilder(item) : item.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: FontFamily.productSans,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
          onChanged: isLoading ? null : onChanged,
          validator: validator,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: FontFamily.productSans,
          ),
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
} 