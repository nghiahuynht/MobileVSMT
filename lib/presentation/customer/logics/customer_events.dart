import 'package:trash_pay/domain/entities/customer/customer.dart';

abstract class CustomerEvents {}

class LoadCustomersEvent extends CustomerEvents {
  final int? pageIndex;
  final int? pageSize;
  final int? groupId;
  final int? areaId;
  final String? search;
  final String? areaSaleCode;
  final String? routeSaleCode;
  LoadCustomersEvent({this.pageIndex, this.pageSize, this.groupId, this.areaId, this.search, this.areaSaleCode, this.routeSaleCode});
}

class LoadMoreCustomersEvent extends CustomerEvents {}

class AddCustomerEvent extends CustomerEvents {
  final CustomerModel customer;
  AddCustomerEvent(this.customer);
}

class UpdateCustomerEvent extends CustomerEvents {
  final CustomerModel customer;
  UpdateCustomerEvent(this.customer);
}

class DeleteCustomerEvent extends CustomerEvents {
  final int customerId;
  DeleteCustomerEvent(this.customerId);
} 