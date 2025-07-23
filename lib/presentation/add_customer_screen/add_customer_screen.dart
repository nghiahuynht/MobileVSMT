import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/presentation/app/logics/app_bloc.dart';
import 'package:trash_pay/presentation/customer/logics/customer_bloc.dart';
import 'package:trash_pay/presentation/customer/logics/customer_events.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';
import 'package:trash_pay/constants/font_family.dart';
import 'package:trash_pay/domain/entities/meta_data/province.dart';
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/meta_data/route.dart' as MetaRoute;

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
  List<MetaRoute.Route> _routes = [];
  MetaRoute.Route? _selectedRoute;

  Ward? _selectedWard;
  Group? _selectedGroup;
  Area? _selectedArea;
  bool _isLoadingWards = false;
  bool _isLoadingGroups = false;
  bool _isLoadingAreas = false;
  Province? _selectedProvince;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
  }

  void _submitForm(BuildContext ctx) {
    if (_formKey.currentState!.validate()) {
      final customerData = CustomerModel(
        id: 0,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        provinceCode: _selectedProvince?.code,
        wardCode: _selectedWard?.code,
        customerGroupCode: _customerGroupController.text.trim(),
        areaSaleCode: _selectedArea?.code,
        routeSaleCode: _selectedRoute?.code,
        price: double.tryParse(_priceController.text) ?? 0.0,
        saleUserCode: ctx.read<AppBloc>().state.userCode
      );

      ctx.read<CustomerBloc>().add(AddCustomerEvent(customerData));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provinces = context.provinces;
    final allAreas = context.areas;
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
                            
                          ),

                          const SizedBox(height: 20),
                          // Province Selection
                          _buildDropdownField<Province>(
                            label: 'Tỉnh/Thành phố',
                            hint: 'Chọn tỉnh/thành phố',
                            icon: Icons.location_on_outlined,
                            value: _selectedProvince,
                            items: provinces,
                            isLoading: false,
                            onChanged: (Province? province) async {
                              setState(() {
                                _selectedProvince = province;
                                _selectedWard = null;
                                _selectedArea = null;
                                _wards = [];
                                _areas = [];
                                _isLoadingWards = true;
                              });
                              if (province?.code != null) {
                                try {
                                  final wards = await DomainManager()
                                      .metaData
                                      .getWardsByProvinceCode(
                                          provinceCode: province!.code!);
                                  setState(() {
                                    _wards = wards;
                                    _isLoadingWards = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _isLoadingWards = false;
                                  });
                                  _showErrorSnackBar(
                                    'Không thể tải danh sách phường/xã',
                                  );
                                }
                              } else {
                                setState(() {
                                  _isLoadingWards = false;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn tỉnh/thành phố';
                              }
                              return null;
                            },
                            itemBuilder: (Province province) =>
                                province.name ?? '',
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
                          // Area Selection
                          _buildDropdownField<Area>(
                            label: 'Khu',
                            hint: 'Chọn khu',
                            icon: Icons.map_outlined,
                            value: _selectedArea,
                            items: _selectedGroup != null
                                ? allAreas
                                    .where((area) =>
                                        area.groupId == _selectedGroup!.id)
                                    .toList()
                                : allAreas,
                            isLoading: false,
                            onChanged: (Area? area) async {
                              setState(() {
                                _selectedArea = area;
                                _selectedRoute = null;
                                _routes = [];
                              });
                              if (area?.code != null) {
                                try {
                                  final routes = await DomainManager()
                                      .metaData
                                      .getAllRouteSaleByAreaSale(
                                          areaSaleCode: area!.code!);
                                  setState(() {
                                    _routes = routes;
                                  });
                                } catch (e) {
                                  _showErrorSnackBar(
                                      'Không thể tải danh sách tuyến');
                                }
                              }
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

                          // Route Selection
                          _buildDropdownField<MetaRoute.Route>(
                            label: 'Tuyến',
                            hint: 'Chọn tuyến',
                            icon: Icons.alt_route_outlined,
                            value: _selectedRoute,
                            items: _routes,
                            isLoading: false,
                            onChanged: (MetaRoute.Route? route) {
                              setState(() {
                                _selectedRoute = route;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn tuyến';
                              }
                              return null;
                            },
                            itemBuilder: (MetaRoute.Route route) =>
                                route.name ?? '',
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
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
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
                          Builder(
                            builder: (buttonContext) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => _submitForm(buttonContext),
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
                              );
                            }
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
