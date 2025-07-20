import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/presentation/customer/add_customer_screen.dart';
import 'package:trash_pay/presentation/customer/logics/customer_bloc.dart';
import 'package:trash_pay/presentation/customer/logics/customer_events.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';
import 'package:trash_pay/presentation/customer/customer_detail_screen.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';
import 'package:intl/intl.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Group? _selectedGroup;
  Area? _selectedArea;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<CustomerBloc>().add(SearchCustomersEvent(_searchController.text));
  }

  void _onGroupChanged(Group? group) {
    setState(() {
      _selectedGroup = group;
    });
    context.read<CustomerBloc>().add(FilterCustomersByGroupEvent(group?.id));
  }

  void _onAreaChanged(Area? area) {
    setState(() {
      _selectedArea = area;
    });
    context.read<CustomerBloc>().add(FilterCustomersByAreaEvent(area?.id));
  }

  void _clearFilters() {
    setState(() {
      _selectedGroup = null;
      _selectedArea = null;
      _searchController.clear();
    });
    context.read<CustomerBloc>().add(ClearFiltersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerBloc()..add(LoadCustomersEvent()),
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
              ProfessionalHeaders.list(
                title: 'Danh Sách Khách Hàng',
                subtitle: 'Quản lý thông tin khách hàng',
                onAddPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddCustomerScreen(),
                    ),
                  );
                  if (result == true) {
                    // Refresh customer list if customer was added successfully
                    context.read<CustomerBloc>().add(LoadCustomersEvent());
                  }
                },
              ),
              
              // Search and Filter Section
              Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm khách hàng...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Filter Row
                    Row(
                      children: [
                        // Group Filter
                        Expanded(
                          child: BlocBuilder<CustomerBloc, CustomerState>(
                            builder: (context, state) {
                              if (state is CustomersLoaded) {
                                return _buildFilterDropdown<Group>(
                                  value: _selectedGroup,
                                  items: state.groups,
                                  hintText: 'Chọn Tổ',
                                  onChanged: _onGroupChanged,
                                  itemBuilder: (Group group) => group.name,
                                );
                              }
                              return _buildFilterDropdown<Group>(
                                value: null,
                                items: [],
                                hintText: 'Chọn Tổ',
                                onChanged: _onGroupChanged,
                                itemBuilder: (Group group) => group.name,
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Area Filter
                        Expanded(
                          child: BlocBuilder<CustomerBloc, CustomerState>(
                            builder: (context, state) {
                              if (state is CustomersLoaded) {
                                // Filter areas based on selected group
                                final availableAreas = _selectedGroup != null
                                    ? state.areas.where((area) => area.groupId == _selectedGroup!.id).toList()
                                    : state.areas;
                                
                                return _buildFilterDropdown<Area>(
                                  value: _selectedArea,
                                  items: availableAreas,
                                  hintText: 'Chọn Khu',
                                  onChanged: _onAreaChanged,
                                  itemBuilder: (Area area) => area.name,
                                );
                              }
                              return _buildFilterDropdown<Area>(
                                value: null,
                                items: [],
                                hintText: 'Chọn Khu',
                                onChanged: _onAreaChanged,
                                itemBuilder: (Area area) => area.name,
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Clear Filters Button
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _clearFilters,
                            icon: const Icon(
                              Icons.clear_all,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            tooltip: 'Xóa bộ lọc',
                          ),
                        ),
                      ],
                    ),
                    
                    // Customer Count Info
                    const SizedBox(height: 16),
                    BlocBuilder<CustomerBloc, CustomerState>(
                      builder: (context, state) {
                        if (state is CustomersLoaded) {
                          final totalCustomers = state.customers.length;
                          final filteredCustomers = state.filteredCustomers.length;
                          final hasFilters = _selectedGroup != null || 
                                           _selectedArea != null || 
                                           _searchController.text.isNotEmpty;
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 20,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hasFilters 
                                        ? 'Hiển thị $filteredCustomers/$totalCustomers khách hàng'
                                        : 'Tổng cộng $totalCustomers khách hàng',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                if (hasFilters) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Đã lọc',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              
              // Customer list
              Expanded(
                child: BlocConsumer<CustomerBloc, CustomerState>(
                  listener: (context, state) {
                    if (state is CustomerOperationSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    } else if (state is CustomerError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: const Color(0xFFDC2626),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CustomerLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF059669),
                        ),
                      );
                    }
                    
                    if (state is CustomersLoaded) {
                      final customers = state.filteredCustomers;
                      
                      if (customers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có khách hàng nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thêm khách hàng mới để bắt đầu',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CustomerDetailScreen(
                                    customer: customers[index],
                                  ),
                                ),
                              );
                            },
                            child: _buildCustomerCard(customers[index]),
                          );
                        },
                      );
                    }
                    
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T? value,
    required List<T> items,
    required String hintText,
    required Function(T?) onChanged,
    required String Function(T) itemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: [
          DropdownMenuItem<T>(
            value: null,
            child: Text(
              hintText,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
          ),
          ...items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemBuilder(item),
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
              ),
            ),
          )).toList(),
        ],
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF64748B),
          size: 20,
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
        ),
      ),
    );
  }
  
  Widget _buildCustomerCard(CustomerModel customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getAvatarColors(customer.status),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Customer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (customer.phone != null)
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer.phone!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

            ],
          ),
          
          if (customer.address != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customer.address!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Location info
          if (customer.groupName != null || customer.areaName != null) ...[
            Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${customer.groupName ?? ''}${customer.groupName != null && customer.areaName != null ? ' - ' : ''}${customer.areaName ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Bottom stats
          Row(
            children: [
              if (customer.totalSpent != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(customer.totalSpent)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (status) {
      case 'active':
        backgroundColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF059669);
        text = 'Hoạt động';
        break;
      case 'inactive':
        backgroundColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        text = 'Không hoạt động';
        break;
      case 'pending':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        text = 'Chờ xử lý';
        break;
      default:
        backgroundColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        text = 'Không xác định';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
  
  List<Color> _getAvatarColors(String status) {
    switch (status) {
      case 'active':
        return [const Color(0xFF059669), const Color(0xFF10B981)];
      case 'inactive':
        return [const Color(0xFFDC2626), const Color(0xFFEF4444)];
      case 'pending':
        return [const Color(0xFFD97706), const Color(0xFFF59E0B)];
      default:
        return [const Color(0xFF64748B), const Color(0xFF94A3B8)];
    }
  }

} 