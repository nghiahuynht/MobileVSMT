import 'package:trash_pay/domain/entities/order/order_item.dart';

class CheckoutRequest {
  final String? customerCode;
  final String? orderDate;
  final String? arrears;
  final String? paymentType;
  final List<OrderItemModel> lstSaleOrderItem;
  final String? saleUserCode;
  final String? note;
  final String? createdBy;
  CheckoutRequest({
    required this.customerCode,
    required this.orderDate,
    required this.arrears,
    required this.paymentType,
    required this.lstSaleOrderItem,
    required this.saleUserCode,
    required this.note,
    required this.createdBy,
  });

  CheckoutRequest copyWith({
    String? customerCode,
    String? orderDate,
    String? arrears,
    String? paymentType,
    List<OrderItemModel>? lstSaleOrderItem,
    String? saleUserCode,
    String? note,
    String? createdBy,
  }) {
    return CheckoutRequest(
      customerCode: customerCode ?? this.customerCode,
      orderDate: orderDate ?? this.orderDate,
      arrears: arrears ?? this.arrears,
      paymentType: paymentType ?? this.paymentType,
      lstSaleOrderItem: lstSaleOrderItem ?? this.lstSaleOrderItem,
      saleUserCode: saleUserCode ?? this.saleUserCode,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'customerCode': customerCode,
      'orderDate': orderDate,
      'arrears': arrears,
      'paymentType': paymentType,
      'lstSaleOrderItem':
          lstSaleOrderItem.map((x) => x.toCreateRequest()).toList(),
      'saleUserCode': saleUserCode,
      'note': note,
      'createdBy': createdBy,
    };
  }
}
