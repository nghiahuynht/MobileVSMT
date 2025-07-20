import 'package:trash_pay/domain/entities/customer/customer.dart';

abstract class CustomerEvents {}

class LoadCustomersEvent extends CustomerEvents {}

class SearchCustomersEvent extends CustomerEvents {
  final String query;
  SearchCustomersEvent(this.query);
}

class FilterCustomersByGroupEvent extends CustomerEvents {
  final int? groupId;
  FilterCustomersByGroupEvent(this.groupId);
}

class FilterCustomersByAreaEvent extends CustomerEvents {
  final int? areaId;
  FilterCustomersByAreaEvent(this.areaId);
}

class ClearFiltersEvent extends CustomerEvents {}

class AddCustomerEvent extends CustomerEvents {
  final CustomerModel customer;
  AddCustomerEvent(this.customer);
}

class UpdateCustomerEvent extends CustomerEvents {
  final CustomerModel customer;
  UpdateCustomerEvent(this.customer);
}

class DeleteCustomerEvent extends CustomerEvents {
  final String customerId;
  DeleteCustomerEvent(this.customerId);
} 