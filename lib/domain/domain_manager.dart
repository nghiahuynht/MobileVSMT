import 'package:trash_pay/domain/repository/auth/auth_repository_impl.dart';
import 'package:trash_pay/domain/repository/customer/customer_repository_impl.dart';
import 'package:trash_pay/domain/repository/meta_data/meta_data_repository_impl.dart';
import 'package:trash_pay/domain/repository/order/order_repository_impl.dart';
import 'package:trash_pay/domain/repository/payment/payment_repository_impl.dart';
import 'package:trash_pay/domain/repository/report/report_repository_impl.dart';
import 'package:trash_pay/domain/repository/unit/unit_repository_impl.dart';

class DomainManager {
  factory DomainManager() {
    _internal ??= DomainManager._();
    return _internal!;
  }
  DomainManager._();
  static DomainManager? _internal;

  final auth = AuthRepositoryImpl();
  final customer = CustomerRepositoryImpl();
  final payment = PaymentRepositoryImpl();
  final order = OrderRepositoryImpl();
  final unit = UnitRepositoryImpl();
  final metaData = MetaDataRepositoryImpl();
  final report = ReportRepositoryImpl();
}
