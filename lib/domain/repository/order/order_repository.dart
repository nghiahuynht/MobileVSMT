import 'package:trash_pay/domain/entities/common/pagination_wrapper_responsive.dart';
import 'package:trash_pay/domain/entities/order/order.dart';
import 'package:trash_pay/domain/entities/order_history_item/order_history_item.dart';

abstract class OrderRepository {
  Future<PaginationWrapperResponsive<OrderModel>> getSaleOrders({
    int pageIndex = 1,
    int pageSize = 10,
    int dateType = 1,
    String searchString = "",
    DateTime? fromDate,
    DateTime? toDate,
    String? routeSaleCode,
    String? areaSaleCode,
    String? saleUserCode,
  });

  Future<OrderModel> getOrderById(int id);

  Future<List<OrderHistoryItemModel>> getSaleOrderByCustomer(String customerCode, int year);

  Future<bool> createOrder(Map<String, dynamic> orderData);

  Future<bool> cancelOrder(int id);
}
