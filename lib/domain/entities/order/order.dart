import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trash_pay/domain/entities/common/base_model.dart';

import 'order_item.dart';

enum OrderStatus {
  newStatus,
  confirmed,
  cancelled;

  String get statusDisplayName {
    switch (this) {
      case OrderStatus.newStatus:
        return 'Mới';
      case OrderStatus.confirmed:
        return 'Đã duyệt';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.newStatus:
        return Colors.grey[300] ?? Colors.grey;
      case OrderStatus.confirmed:
        return const Color(0xFF059669);
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.newStatus:
        return Icons.edit_outlined;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static OrderStatus fromMap(String status) {
    switch (status) {
      case 'new':
        return newStatus;
      default:
        return cancelled;
    }
  }
}

class OrderModel extends BaseModel {
  final int id;
  final String? code;
  final DateTime? orderDate;
  final String? customerCode;
  final String? customerName;
  final String? customerGroupName;
  final String? payerName;
  final String? taxAddress;
  final String? taxCode;
  final String? agencyName;
  final String? arrears;
  final String? arrearsName;
  final String? paymentType;
  final String? paymentName;
  final String? saleUserCode;
  final String? saleUserFullName;
  final OrderStatus orderStatus;
  final String? orderStatusName;
  final DateTime? approveDate;
  final String? note;
  final num? totalNoVAT;
  final num? totalVAT;
  final num? totalWithVAT;
  final String? sourceOrder;
  final String? transactionId;
  final String? uuid;
  final String? invoiceNum;
  final String? invoiceSeries;
  final DateTime? invoiceDate;
  final bool isDeleted;
  final List<OrderItemModel> lstSaleOrderItem;
  final String? createdBy;
  final DateTime? createdDate;
  final String? updatedBy;
  final DateTime? updatedDate;
  OrderModel({
    required this.id,
    this.code,
    this.orderDate,
    this.customerCode,
    this.customerName,
    this.customerGroupName,
    this.payerName,
    this.taxAddress,
    this.taxCode,
    this.agencyName,
    this.arrears,
    this.arrearsName,
    this.paymentType,
    this.paymentName,
    this.saleUserCode,
    this.saleUserFullName,
    required this.orderStatus,
    this.orderStatusName,
    this.approveDate,
    this.note,
    this.totalNoVAT,
    this.totalVAT,
    this.totalWithVAT,
    this.sourceOrder,
    this.transactionId,
    this.uuid,
    this.invoiceNum,
    this.invoiceSeries,
    this.invoiceDate,
    required this.isDeleted,
    required this.lstSaleOrderItem,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
  }) : super(id: id);

  String get statusDisplayName => orderStatus.statusDisplayName;

  int get itemCount =>
      lstSaleOrderItem.fold<int>(0, (sum, item) => sum + item.quantity);

  OrderModel copyWith({
    int? id,
    String? code,
    DateTime? orderDate,
    String? customerCode,
    String? customerName,
    String? customerGroupName,
    String? payerName,
    String? taxAddress,
    String? taxCode,
    String? agencyName,
    String? arrears,
    String? arrearsName,
    String? paymentType,
    String? paymentName,
    String? saleUserCode,
    String? saleUserFullName,
    OrderStatus? orderStatus,
    String? orderStatusName,
    DateTime? approveDate,
    String? note,
    num? totalNoVAT,
    num? totalVAT,
    num? totalWithVAT,
    String? sourceOrder,
    String? transactionId,
    String? uuid,
    String? invoiceNum,
    String? invoiceSeries,
    DateTime? invoiceDate,
    bool? isDeleted,
    List<OrderItemModel>? lstSaleOrderItem,
    String? createdBy,
    DateTime? createdDate,
    String? updatedBy,
    DateTime? updatedDate,
  }) {
    return OrderModel(
      id: id ?? this.id,
      code: code ?? this.code,
      orderDate: orderDate ?? this.orderDate,
      customerCode: customerCode ?? this.customerCode,
      customerName: customerName ?? this.customerName,
      customerGroupName: customerGroupName ?? this.customerGroupName,
      payerName: payerName ?? this.payerName,
      taxAddress: taxAddress ?? this.taxAddress,
      taxCode: taxCode ?? this.taxCode,
      agencyName: agencyName ?? this.agencyName,
      arrears: arrears ?? this.arrears,
      arrearsName: arrearsName ?? this.arrearsName,
      paymentType: paymentType ?? this.paymentType,
      paymentName: paymentName ?? this.paymentName,
      saleUserCode: saleUserCode ?? this.saleUserCode,
      saleUserFullName: saleUserFullName ?? this.saleUserFullName,
      orderStatus: orderStatus ?? this.orderStatus,
      orderStatusName: orderStatusName ?? this.orderStatusName,
      approveDate: approveDate ?? this.approveDate,
      note: note ?? this.note,
      totalNoVAT: totalNoVAT ?? this.totalNoVAT,
      totalVAT: totalVAT ?? this.totalVAT,
      totalWithVAT: totalWithVAT ?? this.totalWithVAT,
      sourceOrder: sourceOrder ?? this.sourceOrder,
      transactionId: transactionId ?? this.transactionId,
      uuid: uuid ?? this.uuid,
      invoiceNum: invoiceNum ?? this.invoiceNum,
      invoiceSeries: invoiceSeries ?? this.invoiceSeries,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      isDeleted: isDeleted ?? this.isDeleted,
      lstSaleOrderItem: lstSaleOrderItem ?? this.lstSaleOrderItem,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'orderDate': orderDate?.millisecondsSinceEpoch,
      'customerCode': customerCode,
      'customerName': customerName,
      'customerGroupName': customerGroupName,
      'payerName': payerName,
      'taxAddress': taxAddress,
      'taxCode': taxCode,
      'agencyName': agencyName,
      'arrears': arrears,
      'arrearsName': arrearsName,
      'paymentType': paymentType,
      'paymentName': paymentName,
      'saleUserCode': saleUserCode,
      'saleUserFullName': saleUserFullName,
      'orderStatus': orderStatus,
      'orderStatusName': orderStatusName,
      'approveDate': approveDate?.millisecondsSinceEpoch,
      'note': note,
      'totalNoVAT': totalNoVAT,
      'totalVAT': totalVAT,
      'totalWithVAT': totalWithVAT,
      'sourceOrder': sourceOrder,
      'transactionId': transactionId,
      'uuid': uuid,
      'invoiceNum': invoiceNum,
      'invoiceSeries': invoiceSeries,
      'invoiceDate': invoiceDate?.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'lstSaleOrderItem': lstSaleOrderItem.map((x) => x.toMap()).toList(),
      'createdBy': createdBy,
      'createdDate': createdDate?.millisecondsSinceEpoch,
      'updatedBy': updatedBy,
      'updatedDate': updatedDate?.millisecondsSinceEpoch,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as int,
      code: map['code'] != null ? map['code'] as String : null,
      orderDate: map['orderDate'] != null
          ? DateTime.tryParse(map['orderDate'] as String)
          : null,
      customerCode:
          map['customerCode'] != null ? map['customerCode'] as String : null,
      customerName:
          map['customerName'] != null ? map['customerName'] as String : null,
      customerGroupName: map['customerGroupName'] != null
          ? map['customerGroupName'] as String
          : null,
      payerName: map['payerName'] != null ? map['payerName'] as String : null,
      taxAddress:
          map['taxAddress'] != null ? map['taxAddress'] as String : null,
      taxCode: map['taxCode'] != null ? map['taxCode'] as String : null,
      agencyName:
          map['agencyName'] != null ? map['agencyName'] as String : null,
      arrears: map['arrears'] != null ? map['arrears'] as String : null,
      arrearsName:
          map['arrearsName'] != null ? map['arrearsName'] as String : null,
      paymentType:
          map['paymentType'] != null ? map['paymentType'] as String : null,
      paymentName:
          map['paymentName'] != null ? map['paymentName'] as String : null,
      saleUserCode:
          map['saleUserCode'] != null ? map['saleUserCode'] as String : null,
      saleUserFullName: map['saleUserFullName'] != null
          ? map['saleUserFullName'] as String
          : null,
      orderStatus: OrderStatus.fromMap(map['orderStatus'] as String? ?? ''),
      orderStatusName: map['orderStatusName'] != null
          ? map['orderStatusName'] as String
          : null,
      approveDate: map['approveDate'] != null
          ? DateTime.tryParse(map['approveDate'] as String)
          : null,
      note: map['note'] != null ? map['note'] as String : null,
      totalNoVAT: map['totalNoVAT'] != null ? map['totalNoVAT'] as num : null,
      totalVAT: map['totalVAT'] != null ? map['totalVAT'] as num : null,
      totalWithVAT:
          map['totalWithVAT'] != null ? map['totalWithVAT'] as num : null,
      sourceOrder:
          map['sourceOrder'] != null ? map['sourceOrder'] as String : null,
      transactionId:
          map['transactionId'] != null ? map['transactionId'] as String : null,
      uuid: map['uuid'] != null ? map['uuid'] as String : null,
      invoiceNum:
          map['invoiceNum'] != null ? map['invoiceNum'] as String : null,
      invoiceSeries:
          map['invoiceSeries'] != null ? map['invoiceSeries'] as String : null,
      invoiceDate: map['invoiceDate'] != null
          ? DateTime.tryParse(map['invoiceDate'] as String)
          : null,
      isDeleted: map['isDeleted'] as bool,
      lstSaleOrderItem: map['lstSaleOrderItem'] != null
          ? List<OrderItemModel>.from(
              (map['lstSaleOrderItem'] as List).map<OrderItemModel>(
                (x) => OrderItemModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      createdBy: map['createdBy'] != null ? map['createdBy'] as String : null,
      createdDate: map['createdDate'] != null
          ? DateTime.tryParse(map['createdDate'] as String)
          : null,
      updatedBy: map['updatedBy'] != null ? map['updatedBy'] as String : null,
      updatedDate: map['updatedDate'] != null
          ? DateTime.tryParse(map['updatedDate'] as String)
          : null,
    );
  }

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source)['data'] as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrderModel(id: $id, code: $code, orderDate: $orderDate, customerCode: $customerCode, customerName: $customerName, customerGroupName: $customerGroupName, payerName: $payerName, taxAddress: $taxAddress, taxCode: $taxCode, agencyName: $agencyName, arrears: $arrears, arrearsName: $arrearsName, paymentType: $paymentType, paymentName: $paymentName, saleUserCode: $saleUserCode, saleUserFullName: $saleUserFullName, orderStatus: $orderStatus, orderStatusName: $orderStatusName, approveDate: $approveDate, note: $note, totalNoVAT: $totalNoVAT, totalVAT: $totalVAT, totalWithVAT: $totalWithVAT, sourceOrder: $sourceOrder, transactionId: $transactionId, uuid: $uuid, invoiceNum: $invoiceNum, invoiceSeries: $invoiceSeries, invoiceDate: $invoiceDate, isDeleted: $isDeleted, lstSaleOrderItem: $lstSaleOrderItem, createdBy: $createdBy, createdDate: $createdDate, updatedBy: $updatedBy, updatedDate: $updatedDate)';
  }

  @override
  bool operator ==(covariant OrderModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.code == code &&
        other.orderDate == orderDate &&
        other.customerCode == customerCode &&
        other.customerName == customerName &&
        other.customerGroupName == customerGroupName &&
        other.payerName == payerName &&
        other.taxAddress == taxAddress &&
        other.taxCode == taxCode &&
        other.agencyName == agencyName &&
        other.arrears == arrears &&
        other.arrearsName == arrearsName &&
        other.paymentType == paymentType &&
        other.paymentName == paymentName &&
        other.saleUserCode == saleUserCode &&
        other.saleUserFullName == saleUserFullName &&
        other.orderStatus == orderStatus &&
        other.orderStatusName == orderStatusName &&
        other.approveDate == approveDate &&
        other.note == note &&
        other.totalNoVAT == totalNoVAT &&
        other.totalVAT == totalVAT &&
        other.totalWithVAT == totalWithVAT &&
        other.sourceOrder == sourceOrder &&
        other.transactionId == transactionId &&
        other.uuid == uuid &&
        other.invoiceNum == invoiceNum &&
        other.invoiceSeries == invoiceSeries &&
        other.invoiceDate == invoiceDate &&
        other.isDeleted == isDeleted &&
        listEquals(other.lstSaleOrderItem, lstSaleOrderItem) &&
        other.createdBy == createdBy &&
        other.createdDate == createdDate &&
        other.updatedBy == updatedBy &&
        other.updatedDate == updatedDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        code.hashCode ^
        orderDate.hashCode ^
        customerCode.hashCode ^
        customerName.hashCode ^
        customerGroupName.hashCode ^
        payerName.hashCode ^
        taxAddress.hashCode ^
        taxCode.hashCode ^
        agencyName.hashCode ^
        arrears.hashCode ^
        arrearsName.hashCode ^
        paymentType.hashCode ^
        paymentName.hashCode ^
        saleUserCode.hashCode ^
        saleUserFullName.hashCode ^
        orderStatus.hashCode ^
        orderStatusName.hashCode ^
        approveDate.hashCode ^
        note.hashCode ^
        totalNoVAT.hashCode ^
        totalVAT.hashCode ^
        totalWithVAT.hashCode ^
        sourceOrder.hashCode ^
        transactionId.hashCode ^
        uuid.hashCode ^
        invoiceNum.hashCode ^
        invoiceSeries.hashCode ^
        invoiceDate.hashCode ^
        isDeleted.hashCode ^
        lstSaleOrderItem.hashCode ^
        createdBy.hashCode ^
        createdDate.hashCode ^
        updatedBy.hashCode ^
        updatedDate.hashCode;
  }
}
