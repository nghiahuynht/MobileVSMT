import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/strings.dart';
import 'package:trash_pay/presentation/order/enum.dart';
import '../../constants/font_family.dart';
import '../../domain/entities/order/order.dart';
import 'logics/order_bloc.dart';
import 'logics/order_events.dart';
import 'logics/order_state.dart';
import 'order_screen.dart';
import '../order_detail/order_detail_screen.dart';
import '../widgets/common/professional_header.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  
  bool _showFilter = false;
  String? _selectedArea;
  String? _selectedRoute;
  String? _selectedSalesUser;
  bool _filterByDate = false;
  int _dateType = 1; // 1: Theo ngày tạo, 2: Theo ngày duyệt
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(InitOrderEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<OrderBloc>().state;
    if (state is OrderListState) {
      if (_isBottom && !state.hasReachedMax && !state.isLoadingMore) {
        context.read<OrderBloc>().add(LoadMoreOrdersEvent());
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Load when reach 90% of scroll
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[50],
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search and Filter Section
            _buildSearchAndFilterSection(),

            // Order List
            Expanded(
              child: _buildOrderList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => OrderBloc(),
                child: const OrderScreen(),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return ProfessionalHeaders.list(
      title: 'Danh sách đơn hàng',
      subtitle: 'Quản lý và theo dõi đơn hàng',
      onBackPressed: () => Navigator.pop(context),
      customActionWidget: GestureDetector(
        onTap: () {
          _showFilterBottomSheet();
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.filter_alt_outlined,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<OrderBloc>().add(SearchOrdersEvent(value));
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đơn hàng...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: FontFamily.productSans,
                ),
                prefixIcon:
                    Icon(Icons.search_outlined, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    // Create temporary variables for the bottom sheet
    String? tempSelectedArea = _selectedArea;
    String? tempSelectedRoute = _selectedRoute;
    String? tempSelectedSalesUser = _selectedSalesUser;
    bool tempFilterByDate = _filterByDate;
    int tempDateType = _dateType;
    DateTime? tempFromDate = _fromDate;
    DateTime? tempToDate = _toDate;
    TextEditingController tempFromDateController = TextEditingController();
    TextEditingController tempToDateController = TextEditingController();
    
    // Initialize temp controllers with current values
    if (_fromDate != null) {
      tempFromDateController.text = '${_fromDate!.day.toString().padLeft(2, '0')}/${_fromDate!.month.toString().padLeft(2, '0')}/${_fromDate!.year}';
    }
    if (_toDate != null) {
      tempToDateController.text = '${_toDate!.day.toString().padLeft(2, '0')}/${_toDate!.month.toString().padLeft(2, '0')}/${_toDate!.year}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Bộ lọc',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.productSans,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelectedArea = null;
                              tempSelectedRoute = null;
                              tempSelectedSalesUser = null;
                              tempFilterByDate = false;
                              tempDateType = 1;
                              tempFromDate = null;
                              tempToDate = null;
                              tempFromDateController.clear();
                              tempToDateController.clear();
                            });
                          },
                          child: Text(
                            'Xóa tất cả',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: FontFamily.productSans,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Filter content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Area, Route Row
                          Row(
                            children: [
                              // Area Filter
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Khu vực',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: FontFamily.productSans,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModalDropdownField(
                                      value: tempSelectedArea,
                                      hint: 'Chọn khu vực',
                                      items: ['Khu vực 1', 'Khu vực 2', 'Khu vực 3'],
                                      onChanged: (value) {
                                        setModalState(() {
                                          tempSelectedArea = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Route Filter
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.route_outlined, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tuyến',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: FontFamily.productSans,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModalDropdownField(
                                      value: tempSelectedRoute,
                                      hint: 'Chọn Tuyến',
                                      items: ['Tuyến A', 'Tuyến B', 'Tuyến C'],
                                      onChanged: (value) {
                                        setModalState(() {
                                          tempSelectedRoute = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Sales User Filter
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Nhân viên bán hàng',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: FontFamily.productSans,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildModalDropdownField(
                                value: tempSelectedSalesUser,
                                hint: 'Chọn Nhân viên bán hàng',
                                items: ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C'],
                                onChanged: (value) {
                                  setModalState(() {
                                    tempSelectedSalesUser = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Date Filter Section
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Theo ngày',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: FontFamily.productSans,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: tempFilterByDate,
                                onChanged: (value) {
                                  setModalState(() {
                                    tempFilterByDate = value;
                                    if (!value) {
                                      tempFromDate = null;
                                      tempToDate = null;
                                      tempFromDateController.clear();
                                      tempToDateController.clear();
                                    }
                                  });
                                },
                                activeColor: const Color(0xFF059669),
                              ),
                            ],
                          ),
                          
                          if (tempFilterByDate) ...[
                            const SizedBox(height: 16),
                            
                            // Date Type Selection
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF059669).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Loại ngày',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: FontFamily.productSans,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildModalDateTypeOption(
                                          title: 'Theo ngày tạo',
                                          value: 1,
                                          groupValue: tempDateType,
                                          onChanged: (value) {
                                            setModalState(() {
                                              tempDateType = value!;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildModalDateTypeOption(
                                          title: 'Theo ngày duyệt',
                                          value: 2,
                                          groupValue: tempDateType,
                                          onChanged: (value) {
                                            setModalState(() {
                                              tempDateType = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                // From Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.date_range_outlined, size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Từ ngày',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: FontFamily.productSans,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildModalDateField(
                                        controller: tempFromDateController,
                                        hint: '14/07/2025',
                                        onTap: () async {
                                          final picked = await _selectModalDate(
                                            context,
                                            tempFromDate ?? DateTime.now(),
                                            DateTime(2020),
                                            DateTime.now(),
                                          );
                                          if (picked != null) {
                                            setModalState(() {
                                              tempFromDate = picked;
                                              tempFromDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // To Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.date_range_outlined, size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Đến ngày',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: FontFamily.productSans,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildModalDateField(
                                        controller: tempToDateController,
                                        hint: '20/07/2025',
                                        onTap: () async {
                                          final picked = await _selectModalDate(
                                            context,
                                            tempToDate ?? DateTime.now(),
                                            tempFromDate ?? DateTime(2020),
                                            DateTime.now(),
                                          );
                                          if (picked != null) {
                                            setModalState(() {
                                              tempToDate = picked;
                                              tempToDateController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                fontFamily: FontFamily.productSans,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              // Apply filters
                              setState(() {
                                _selectedArea = tempSelectedArea;
                                _selectedRoute = tempSelectedRoute;
                                _selectedSalesUser = tempSelectedSalesUser;
                                _filterByDate = tempFilterByDate;
                                _dateType = tempDateType;
                                _fromDate = tempFromDate;
                                _toDate = tempToDate;
                                _fromDateController.text = tempFromDateController.text;
                                _toDateController.text = tempToDateController.text;
                              });
                              
                              // Call API with filters
                              context.read<OrderBloc>().add(FilterOrdersByMultipleCriteriaEvent(
                                areaSaleCode: tempSelectedArea,
                                routeSaleCode: tempSelectedRoute,
                                saleUserCode: tempSelectedSalesUser,
                                dateType: tempFilterByDate ? tempDateType : null,
                                fromDate: tempFilterByDate ? tempFromDate : null,
                                toDate: tempFilterByDate ? tempToDate : null,
                              ));
                              
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Áp dụng lọc',
                              style: TextStyle(
                                fontFamily: FontFamily.productSans,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Cleanup temp controllers
      tempFromDateController.dispose();
      tempToDateController.dispose();
    });
  }

  // Helper widgets for bottom sheet
  Widget _buildModalDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontFamily: FontFamily.productSans,
            ),
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: FontFamily.productSans,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildModalDateField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text.isEmpty ? hint : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty ? Colors.grey[500] : Colors.black87,
                  fontSize: 14,
                  fontFamily: FontFamily.productSans,
                ),
              ),
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildModalDateTypeOption({
    required String title,
    required int value,
    required int groupValue,
    required ValueChanged<int?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF059669),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontFamily: FontFamily.productSans,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectModalDate(
    BuildContext context,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF059669),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Widget _buildOrderList() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
              ),
            );
          }
      
          if (state is OrderListState) {
            return Column(
              children: [
                // Order count summary
                if (state.filteredOrders.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF059669).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 20,
                          color: const Color(0xFF059669),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hiển thị ${state.filteredOrders.length} trong tổng số ${state.totalItem} đơn hàng',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF059669),
                            fontFamily: FontFamily.productSans,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Order list
                if (state.filteredOrders.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có đơn hàng nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: FontFamily.productSans,
                          ),
                        ),
                        if (state.searchQuery.isNotEmpty ||
                            _selectedArea != null ||
                            _selectedRoute != null ||
                            _selectedSalesUser != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Thử thay đổi bộ lọc hoặc tìm kiếm',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontFamily: FontFamily.productSans,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = state.filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                  
                  // Loading more indicator
                  if (state.isLoadingMore)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                        ),
                      ),
                    ),
                  
                  // End of list indicator
                  if (state.hasReachedMax && state.filteredOrders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Đã hiển thị tất cả đơn hàng',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontFamily: FontFamily.productSans,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                    ),
                ],
              ],
            );
          }
      
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showOrderDetail(order);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with order number and status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng #${order.code}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: FontFamily.productSans,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tạo lúc: ${_formatDateTime(order.createdDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: FontFamily.productSans,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(order.orderStatus),
                  ],
                ),

                const SizedBox(height: 12),

                // Customer info - Enhanced with better styling
                if (order.customerName != null &&
                    order.customerName!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF059669).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 18,
                          color: const Color(0xFF059669),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khách hàng',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFF059669),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: FontFamily.productSans,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.customerName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                  fontFamily: FontFamily.productSans,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),

                // Order summary
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      'Tổng: ${_formatCurrency(order.totalNoVAT?.toDouble())}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF059669),
                        fontFamily: FontFamily.productSans,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color textColor = Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusDisplayName(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return Strings.defaultEmpty;
    }

    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double? amount) {
    if (amount == null) {
      return Strings.defaultEmpty;
    }

    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
  }

  String _getStatusDisplayName(OrderStatus status) {
    return status.statusDisplayName;
  }

  void _showOrderDetail(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );
  }
}
