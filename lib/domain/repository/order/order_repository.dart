import 'package:trash_pay/domain/entities/common/pagination_wrapper_responsive.dart';
import 'package:trash_pay/domain/entities/order/order.dart';

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

  Future<bool> createOrder(Map<String, dynamic> orderData);
}
