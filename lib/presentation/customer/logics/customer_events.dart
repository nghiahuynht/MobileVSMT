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
  final String? saleUserCode;
  LoadCustomersEvent({
    this.pageIndex,
    this.pageSize,
    this.groupId,
    this.areaId,
    this.search,
    this.areaSaleCode,
    this.routeSaleCode,
    this.saleUserCode,
  });
}

class LoadMoreCustomersEvent extends CustomerEvents {
  final String? saleUserCode;
  LoadMoreCustomersEvent({this.saleUserCode});
}

class AddCustomerEvent extends CustomerEvents {
  final CustomerModel customer;
  final bool isEdit;
  AddCustomerEvent(this.customer, {this.isEdit = false});
}
