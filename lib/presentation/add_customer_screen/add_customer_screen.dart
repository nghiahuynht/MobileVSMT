import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/colors.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/ward.dart';
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
import 'package:trash_pay/services/app_messenger.dart';

class AddCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;
  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  late bool isEdit;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _villageController = TextEditingController();
  final _priceController = TextEditingController();

  List<MetaRoute.Route> _routes = [];

  MetaRoute.Route? _selectedRoute;
  Ward? _selectedWard;
  Group? _selectedGroup;
  Area? _selectedArea;
  final bool _isLoadingWards = false;
  Province? _selectedProvince;

  @override
  void initState() {
    isEdit = widget.customer != null;

    if (widget.customer != null) {
      _nameController.text = widget.customer!.name ?? '';
      _phoneController.text = widget.customer!.phone ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _villageController.text = widget.customer!.village ?? '';
      _priceController.text = widget.customer!.currentPrice?.toInt().toString() ?? '';
      _selectedProvince = context.provinces
          .where((province) => province.code == widget.customer!.provinceCode)
          .firstOrNull;
      _selectedWard = context.wards
          .where((ward) => ward.code == widget.customer!.wardCode)
          .firstOrNull;
      _selectedArea = context.areas
          .where((area) => area.code == widget.customer!.areaSaleCode)
          .firstOrNull;
      _selectedGroup = context.groups
          .where((group) => group.code == widget.customer!.customerGroupCode)
          .firstOrNull;

      getRoute(_selectedArea?.code ?? '',
          selectData: widget.customer!.routeSaleCode);
    }

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _villageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: const Color(0xFFDC2626),
  //     ),
  //   );
  // }

  void _submitForm(BuildContext ctx) {
    if (_formKey.currentState!.validate()) {
      final customerData = CustomerModel(
          id: widget.customer?.id ?? 0,
          code: widget.customer?.code ?? '',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          provinceCode: _selectedProvince?.code,
          wardCode: _selectedWard?.code,
          customerGroupCode: _selectedGroup?.code,
          customerGroupName: _selectedGroup?.name,
          areaSaleCode: _selectedArea?.code,
          areaSaleName: _selectedArea?.name,
          routeSaleCode: _selectedRoute?.code,
          routeSaleName: _selectedRoute?.name,
          village: _villageController.text.trim(),
          currentPrice: double.tryParse(_priceController.text) ?? 0.0,
          saleUserCode: ctx.read<AppBloc>().state.userCode);

      ctx.read<CustomerBloc>().add(AddCustomerEvent(customerData, isEdit: isEdit));
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
            // keep success toast here if desired; otherwise could use AppMessenger.showSuccess
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );


            final customerData = CustomerModel(
          id: widget.customer?.id ?? 0,
          code: widget.customer?.code ?? '',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          provinceCode: _selectedProvince?.code,
          wardCode: _selectedWard?.code,
          customerGroupCode: _selectedGroup?.code,
          customerGroupName: _selectedGroup?.name,
          areaSaleCode: _selectedArea?.code,
          areaSaleName: _selectedArea?.name,
          routeSaleCode: _selectedRoute?.code,
          routeSaleName: _selectedRoute?.name,
          village: _villageController.text.trim(),
          currentPrice: double.tryParse(_priceController.text) ?? 0.0,
          saleUserCode: context.read<AppBloc>().state.userCode);

            Navigator.of(context).pop(customerData);
          } else if (state is CustomerError) {
            AppMessenger.showError("Đã có lỗi xảy ra");
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
                  title: isEdit ? "Chỉnh sửa khách hàng" : 'Thêm Khách Hàng',
                  subtitle: isEdit ? "Cập nhật thông tin khách hàng" : 'Nhập thông tin khách hàng mới',
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
                              });
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
                            items: _selectedProvince != null
                                ? context.appState.wards
                                    .where(
                                      (ward) =>
                                          ward.parentCode ==
                                          _selectedProvince!.code,
                                    )
                                    .toList()
                                : [],
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
                            itemBuilder: (Ward ward) => ward.name ?? '',
                          ),

                          const SizedBox(height: 20),

                          // village
                          _buildTextField(
                            controller: _villageController,
                            label: 'Tổ/Thôn',
                            hint: 'Nhập Tổ/Thôn',
                            icon: Icons.groups,
                            maxLines: 3,
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
                            items: allAreas,
                            isLoading: false,
                            onChanged: (Area? area) async {
                              setState(() {
                                _selectedArea = area;
                                _selectedRoute = null;
                                _routes = [];
                              });
                              if (area?.code != null) {
                                getRoute(area!.code);
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

                          _buildDropdownField<Group>(
                            label: 'Loại hình kinh doanh',
                            hint: 'Chọn loại hình kinh doanh',
                            icon: Icons.map_outlined,
                            value: _selectedGroup,
                            items: context.appState.groups,
                            isLoading: false,
                            onChanged: (Group? value) async {
                              setState(() {
                                _selectedGroup = value;
                              });
                            },
                            itemBuilder: (Group area) => area.label ?? '',
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
                          Builder(builder: (buttonContext) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => _submitForm(buttonContext),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
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
                          }),
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

  void getRoute(String areaSaleCode, {String? selectData}) async {
    try {
      final routes = await DomainManager()
          .metaData
          .getAllRouteSaleByAreaSale(areaSaleCode: areaSaleCode);
      setState(() {
        _routes = routes;
      });

      if (selectData != null) {
        _selectedRoute =
            _routes.where((route) => route.code == selectData).firstOrNull;
      }
    } catch (e) {
      // _showErrorSnackBar('Không thể tải danh sách tuyến');
    }
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
