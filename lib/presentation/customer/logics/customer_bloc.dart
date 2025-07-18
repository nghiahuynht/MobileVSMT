import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/presentation/customer/logics/customer_events.dart';
import 'package:trash_pay/presentation/customer/logics/customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvents, CustomerState> {
  CustomerBloc() : super(CustomerInitial()) {
    on<LoadCustomersEvent>(_handleLoadCustomers);
    on<SearchCustomersEvent>(_handleSearchCustomers);
    on<AddCustomerEvent>(_handleAddCustomer);
    on<UpdateCustomerEvent>(_handleUpdateCustomer);
    on<DeleteCustomerEvent>(_handleDeleteCustomer);
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();
  List<CustomerModel> _allCustomers = [];

  Future<void> _handleLoadCustomers(
      LoadCustomersEvent event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      // Simulated data - replace with actual repository call
      _allCustomers = _generateMockCustomers();
      emit(CustomersLoaded(_allCustomers));
    } catch (e) {
      emit(CustomerError('Không thể tải danh sách khách hàng: ${e.toString()}'));
    }
  }

  Future<void> _handleSearchCustomers(
      SearchCustomersEvent event, Emitter<CustomerState> emit) async {
    if (_allCustomers.isEmpty) return;
    
    if (event.query.isEmpty) {
      emit(CustomersLoaded(_allCustomers));
      return;
    }

    final filteredCustomers = _allCustomers.where((customer) =>
        customer.name.toLowerCase().contains(event.query.toLowerCase()) ||
        (customer.phone?.contains(event.query) ?? false) ||
        (customer.email?.toLowerCase().contains(event.query.toLowerCase()) ?? false)
    ).toList();

    emit(CustomersLoaded(_allCustomers, filteredCustomers: filteredCustomers));
  }

  Future<void> _handleAddCustomer(
      AddCustomerEvent event, Emitter<CustomerState> emit) async {
    try {
      // Simulated add - replace with actual repository call
      _allCustomers.add(event.customer);
      emit(CustomerOperationSuccess('Đã thêm khách hàng thành công'));
      emit(CustomersLoaded(_allCustomers));
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
        emit(CustomersLoaded(_allCustomers));
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
      emit(CustomersLoaded(_allCustomers));
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
      ),
    ];
  }
} 