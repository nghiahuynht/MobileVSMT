// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/route.dart';
import 'package:trash_pay/presentation/order/enum.dart';

abstract class OrderEvent {}

// Customer selection
class SelectCustomerEvent extends OrderEvent {
  final CustomerModel? customer;
  SelectCustomerEvent(this.customer);
}

// Order creation
class CreateOrderEvent extends OrderEvent {
  final String? notes;
  CreateOrderEvent({this.notes});
}

// Order management
class InitOrderEvent extends OrderEvent {
  final String? saleUserCode;
  InitOrderEvent({
    this.saleUserCode,
  });

  InitOrderEvent copyWith({
    String? saleUserCode,
  }) {
    return InitOrderEvent(
      saleUserCode: saleUserCode ?? this.saleUserCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'saleUserCode': saleUserCode,
    };
  }

  factory InitOrderEvent.fromMap(Map<String, dynamic> map) {
    return InitOrderEvent(
      saleUserCode: map['saleUserCode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory InitOrderEvent.fromJson(String source) => InitOrderEvent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'InitOrderEvent(saleUserCode: $saleUserCode)';

  @override
  bool operator ==(covariant InitOrderEvent other) {
    if (identical(this, other)) return true;
  
    return 
      other.saleUserCode == saleUserCode;
  }

  @override
  int get hashCode => saleUserCode.hashCode;
}

class LoadOrderDetailEvent extends OrderEvent {
  final String orderId;
  LoadOrderDetailEvent(this.orderId);
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final String status;

  UpdateOrderStatusEvent({
    required this.orderId,
    required this.status,
  });
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;
  CancelOrderEvent(this.orderId);
}

// Order list management
class SearchOrdersEvent extends OrderEvent {
  final String query;
  SearchOrdersEvent(this.query);
}

// Pagination events
class LoadMoreOrdersEvent extends OrderEvent {}

class GetOrderDetailEvent extends OrderEvent {
  final String orderId;
  GetOrderDetailEvent(this.orderId);
}

class FilterOrdersByMultipleCriteriaEvent extends OrderEvent {
  final Area? selectedArea;
  final Route? selectedRoute;
  final String? saleUserCode;
  final int? dateType; // 1: Theo ngày tạo, 2: Theo ngày duyệt
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<Route> routes;

  FilterOrdersByMultipleCriteriaEvent({
    this.selectedArea,
    this.selectedRoute,
    this.saleUserCode,
    this.dateType,
    this.fromDate,
    this.toDate,
    this.routes = const [],
  });
}
