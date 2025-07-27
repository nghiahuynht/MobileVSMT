import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/arrear.dart';
import 'package:trash_pay/domain/entities/meta_data/payment_type.dart';
import 'package:trash_pay/domain/entities/meta_data/ward.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/province.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/presentation/app/logics/app_bloc.dart';
import 'package:trash_pay/presentation/app/logics/app_events.dart';
import 'package:trash_pay/presentation/app/logics/app_state.dart';
import 'package:trash_pay/presentation/widgets/common_circular_progess_indicator.dart';

/// Extension để dễ dàng truy cập AppBloc từ BuildContext
extension AppBlocExtension on BuildContext {
  /// Lấy AppBloc instance
  AppBloc get appBloc => read<AppBloc>();

  /// Lấy AppState hiện tại
  AppState get appState => read<AppBloc>().state;

  /// Lấy danh sách areas
  List<Area> get areas => appState.areas;

  /// Lấy danh sách products
  List<ProductModel> get products => appState.products;

  /// Lấy danh sách groups
  List<Group> get groups => appState.groups;

  /// Lấy danh sách provinces
  List<Province> get provinces => appState.provinces;

  /// Lấy danh sách wards
  List<Ward> get wards => appState.wards;

  /// Kiểm tra app đã khởi tạo xong chưa
  bool get isAppInitialized => appState.isInitialized;

  /// Lấy user code
  String? get userCode => appState.userCode;

  /// Lấy danh sách arrears
  List<Arrear> get arrears => appState.arrears;

  /// Lấy danh sách payment types
  List<PaymentType> get paymentTypes => appState.paymentTypes;

  /// Gọi reload areas
  void reloadAreas() {
    appBloc.add(LoadAreasAfterLogin());
  }
}

/// Extension để truy cập AppBloc từ bất kỳ đâu (không cần BuildContext)
class AppBlocHelper {
  /// Lấy AppBloc instance từ GetIt
  static AppBloc get instance => GetIt.I<AppBloc>();

  /// Lấy AppState hiện tại
  static AppState get state => instance.state;

  /// Lấy danh sách areas
  static List<Area> get areas => state.areas;

  /// Kiểm tra app đã khởi tạo xong chưa
  static bool get isAppInitialized => state.isInitialized;

  /// Gọi reload areas
  static void reloadAreas() {
    instance.add(LoadAreasAfterLogin());
  }
}

/// Widget helper để listen changes của areas
class AreasBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, List<Area> areas) builder;
  final Widget Function(BuildContext context)? loadingBuilder;

  const AreasBuilder({
    super.key,
    required this.builder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (!state.isInitialized && loadingBuilder != null) {
          return loadingBuilder!(context);
        }

        return builder(context, state.areas);
      },
    );
  }
}

/// Widget để hiển thị loading khi app chưa khởi tạo xong
class AppInitializationBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context)? loadingBuilder;

  const AppInitializationBuilder({
    super.key,
    required this.builder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (!state.isInitialized) {
          return loadingBuilder?.call(context) ??
              const Center(child: XCircularProgressIndicator());
        }

        return builder(context);
      },
    );
  }
}
