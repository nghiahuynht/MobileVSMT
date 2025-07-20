import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/presentation/customer/logics/customer_events.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvents, CustomerState> {
  CustomerBloc() : super(CustomerInitial()) {
    on<LoadCustomersEvent>(_handleLoadCustomers);
    on<SearchCustomersEvent>(_handleSearchCustomers);
    on<FilterCustomersByGroupEvent>(_handleFilterByGroup);
    on<FilterCustomersByAreaEvent>(_handleFilterByArea);
    on<ClearFiltersEvent>(_handleClearFilters);
    on<AddCustomerEvent>(_handleAddCustomer);
    on<UpdateCustomerEvent>(_handleUpdateCustomer);
    on<DeleteCustomerEvent>(_handleDeleteCustomer);
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();
  List<CustomerModel> _allCustomers = [];
  List<Group> _allGroups = [];
  List<Area> _allAreas = [];
  String _currentSearchQuery = '';
  int? _currentGroupId;
  int? _currentAreaId;

  Future<void> _handleLoadCustomers(
      LoadCustomersEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      // Simulated data - replace with actual repository call
      _allCustomers = _generateMockCustomers();
      _allGroups = _generateMockGroups();
      _allAreas = _generateMockAreas();
      
      emit(CustomersLoaded(
        _allCustomers,
        groups: _allGroups,
        areas: _allAreas,
      ));
    } catch (e) {
      emit(CustomerError('Không thể tải danh sách khách hàng: ${e.toString()}'));
    }
  }

  Future<void> _handleSearchCustomers(
      SearchCustomersEvent event, Emitter<CustomerState> emit) async {
    if (_allCustomers.isEmpty) return;
    
    _currentSearchQuery = event.query;
    final filteredCustomers = _applyFilters();
    
    emit(CustomersLoaded(
      _allCustomers,
      filteredCustomers: filteredCustomers,
      groups: _allGroups,
      areas: _allAreas,
      searchQuery: _currentSearchQuery,
      selectedGroupId: _currentGroupId,
      selectedAreaId: _currentAreaId,
    ));
  }

  Future<void> _handleFilterByGroup(
      FilterCustomersByGroupEvent event, Emitter<CustomerState> emit) async {
    if (_allCustomers.isEmpty) return;
    
    _currentGroupId = event.groupId;
    final filteredCustomers = _applyFilters();
    
    emit(CustomersLoaded(
      _allCustomers,
      filteredCustomers: filteredCustomers,
      groups: _allGroups,
      areas: _allAreas,
      searchQuery: _currentSearchQuery,
      selectedGroupId: _currentGroupId,
      selectedAreaId: _currentAreaId,
    ));
  }

  Future<void> _handleFilterByArea(
      FilterCustomersByAreaEvent event, Emitter<CustomerState> emit) async {
    if (_allCustomers.isEmpty) return;
    
    _currentAreaId = event.areaId;
    final filteredCustomers = _applyFilters();
    
    emit(CustomersLoaded(
      _allCustomers,
      filteredCustomers: filteredCustomers,
      groups: _allGroups,
      areas: _allAreas,
      searchQuery: _currentSearchQuery,
      selectedGroupId: _currentGroupId,
      selectedAreaId: _currentAreaId,
    ));
  }

  Future<void> _handleClearFilters(
      ClearFiltersEvent event, Emitter<CustomerState> emit) async {
    if (_allCustomers.isEmpty) return;
    
    _currentSearchQuery = '';
    _currentGroupId = null;
    _currentAreaId = null;
    
    emit(CustomersLoaded(
      _allCustomers,
      groups: _allGroups,
      areas: _allAreas,
    ));
  }

  List<CustomerModel> _applyFilters() {
    List<CustomerModel> filtered = _allCustomers;

    // Apply search filter
    if (_currentSearchQuery.isNotEmpty) {
      filtered = filtered.where((customer) =>
          customer.name.toLowerCase().contains(_currentSearchQuery.toLowerCase()) ||
          (customer.phone?.contains(_currentSearchQuery) ?? false) ||
          (customer.email?.toLowerCase().contains(_currentSearchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Apply group filter
    if (_currentGroupId != null) {
      filtered = filtered.where((customer) => customer.groupId == _currentGroupId).toList();
    }

    // Apply area filter
    if (_currentAreaId != null) {
      filtered = filtered.where((customer) => customer.areaId == _currentAreaId).toList();
    }

    return filtered;
  }

  Future<void> _handleAddCustomer(
      AddCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      // Simulated add - replace with actual repository call
      _allCustomers.add(event.customer);
      emit(CustomerOperationSuccess('Đã thêm khách hàng thành công'));
      emit(CustomersLoaded(
        _allCustomers,
        groups: _allGroups,
        areas: _allAreas,
        searchQuery: _currentSearchQuery,
        selectedGroupId: _currentGroupId,
        selectedAreaId: _currentAreaId,
      ));
    } catch (e) {
      emit(CustomerError('Không thể thêm khách hàng: ${e.toString()}'));
    }
  }

  Future<void> _handleUpdateCustomer(
      UpdateCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      // Simulated update - replace with actual repository call
      final index = _allCustomers.indexWhere((c) => c.id == event.customer.id);
      if (index != -1) {
        _allCustomers[index] = event.customer;
        emit(CustomerOperationSuccess('Đã cập nhật khách hàng thành công'));
        emit(CustomersLoaded(
          _allCustomers,
          groups: _allGroups,
          areas: _allAreas,
          searchQuery: _currentSearchQuery,
          selectedGroupId: _currentGroupId,
          selectedAreaId: _currentAreaId,
        ));
      }
    } catch (e) {
      emit(CustomerError('Không thể cập nhật khách hàng: ${e.toString()}'));
    }
  }

  Future<void> _handleDeleteCustomer(
      DeleteCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      // Simulated delete - replace with actual repository call
      _allCustomers.removeWhere((c) => c.id == event.customerId);
      emit(CustomerOperationSuccess('Đã xóa khách hàng thành công'));
      emit(CustomersLoaded(
        _allCustomers,
        groups: _allGroups,
        areas: _allAreas,
        searchQuery: _currentSearchQuery,
        selectedGroupId: _currentGroupId,
        selectedAreaId: _currentAreaId,
      ));
    } catch (e) {
      emit(CustomerError('Không thể xóa khách hàng: ${e.toString()}'));
    }
  }

  // Mock data generator - replace with actual repository
  List<CustomerModel> _generateMockCustomers() {
    return [
      CustomerModel(
        id: '1',
        name: 'Nguyễn Văn An',
        phone: '0901234567',
        address: '123 Đường ABC, Quận 1, TP.HCM',
        email: 'nguyenvanan@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        totalSpent: 2500000,
        status: 'active',
        wardId: 1,
        wardName: 'Phường 1',
        groupId: 1,
        groupName: 'Tổ 1',
        areaId: 1,
        areaName: 'Khu A',
        customerGroup: 'vip',
        price: 50000,
      ),
      CustomerModel(
        id: '2',
        name: 'Trần Thị Bình',
        phone: '0987654321',
        address: '456 Đường XYZ, Quận 3, TP.HCM',
        email: 'tranthibinh@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        totalSpent: 1800000,
        status: 'active',
        wardId: 2,
        wardName: 'Phường 2',
        groupId: 4,
        groupName: 'Tổ 1',
        areaId: 7,
        areaName: 'Khu A',
        customerGroup: 'regular',
        price: 45000,
      ),
      CustomerModel(
        id: '3',
        name: 'Lê Văn Cường',
        phone: '0912345678',
        address: '789 Đường DEF, Quận 7, TP.HCM',
        email: 'levancuong@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        totalSpent: 3200000,
        status: 'active',
        wardId: 1,
        wardName: 'Phường 1',
        groupId: 2,
        groupName: 'Tổ 2',
        areaId: 4,
        areaName: 'Khu A',
        customerGroup: 'premium',
        price: 60000,
      ),
      CustomerModel(
        id: '4',
        name: 'Phạm Thị Dung',
        phone: '0923456789',
        address: '321 Đường GHI, Quận 5, TP.HCM',
        email: 'phamthidung@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        totalSpent: 1200000,
        status: 'inactive',
        wardId: 3,
        wardName: 'Phường 3',
        groupId: 6,
        groupName: 'Tổ 1',
        areaId: 10,
        areaName: 'Khu A',
        customerGroup: 'regular',
        price: 45000,
      ),
      CustomerModel(
        id: '5',
        name: 'Hoàng Văn Em',
        phone: '0934567890',
        address: '654 Đường JKL, Quận 2, TP.HCM',
        email: 'hoangvanem@email.com',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        totalSpent: 850000,
        status: 'pending',
        wardId: 4,
        wardName: 'Phường 4',
        groupId: 8,
        groupName: 'Tổ 1',
        areaId: 11,
        areaName: 'Khu A',
        customerGroup: 'vip',
        price: 50000,
      ),
    ];
  }

  List<Group> _generateMockGroups() {
    return [
      Group(id: 1, code: 'T1', name: 'Tổ 1', wardId: 1),
      Group(id: 2, code: 'T2', name: 'Tổ 2', wardId: 1),
      Group(id: 3, code: 'T3', name: 'Tổ 3', wardId: 1),
      Group(id: 4, code: 'T1', name: 'Tổ 1', wardId: 2),
      Group(id: 5, code: 'T2', name: 'Tổ 2', wardId: 2),
      Group(id: 6, code: 'T1', name: 'Tổ 1', wardId: 3),
      Group(id: 7, code: 'T2', name: 'Tổ 2', wardId: 3),
      Group(id: 8, code: 'T1', name: 'Tổ 1', wardId: 4),
    ];
  }

  List<Area> _generateMockAreas() {
    return [
      Area(id: 1, code: 'A1', name: 'Khu A', groupId: 1),
      Area(id: 2, code: 'A2', name: 'Khu B', groupId: 1),
      Area(id: 3, code: 'A3', name: 'Khu C', groupId: 1),
      Area(id: 4, code: 'A1', name: 'Khu A', groupId: 2),
      Area(id: 5, code: 'A2', name: 'Khu B', groupId: 2),
      Area(id: 6, code: 'A1', name: 'Khu A', groupId: 3),
      Area(id: 7, code: 'A1', name: 'Khu A', groupId: 4),
      Area(id: 8, code: 'A2', name: 'Khu B', groupId: 4),
      Area(id: 9, code: 'A1', name: 'Khu A', groupId: 5),
      Area(id: 10, code: 'A1', name: 'Khu A', groupId: 6),
      Area(id: 11, code: 'A1', name: 'Khu A', groupId: 8),
    ];
  }
} 