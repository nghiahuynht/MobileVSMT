import 'package:equatable/equatable.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/arrear.dart';
import 'package:trash_pay/domain/entities/meta_data/payment_type.dart';
import 'package:trash_pay/domain/entities/meta_data/province.dart';
import 'package:trash_pay/domain/entities/meta_data/ward.dart';
import 'package:trash_pay/domain/entities/product/product.dart';

class AppState extends Equatable {
  final List<Area> areas;
  final List<Province> provinces;
  final List<Group> groups;
  final List<ProductModel> products;
  final List<Arrear> arrears;
  final List<Ward> wards;
  final List<PaymentType> paymentTypes;
  final String? userCode;
  final bool isInitialized;

  const AppState({
    this.areas = const [],
    this.groups = const [],
    this.provinces = const [],
    this.products = const [],
    this.arrears = const [],
    this.wards = const [],
    this.paymentTypes = const [],
    this.isInitialized = false,
    this.userCode,
  });

  factory AppState.initial() {
    return const AppState();
  }

  AppState copyWith({
    List<Area>? areas,
    List<Province>? provinces,
    bool? isInitialized,
    String? userCode,
    List<Group>? groups,
    List<ProductModel>? products,
    List<Arrear>? arrears,
    List<Ward>? wards, 
    List<PaymentType>? paymentTypes,
  }) {
    return AppState(
      areas: areas ?? this.areas,
      provinces: provinces ?? this.provinces,
      isInitialized: isInitialized ?? this.isInitialized,
      userCode: userCode ?? this.userCode,
      products: products ?? this.products,
      arrears: arrears ?? this.arrears,
      wards: wards ?? this.wards,
      paymentTypes: paymentTypes ?? this.paymentTypes,
    );
  }

  @override
  List<Object?> get props =>
      [areas, provinces, isInitialized, userCode, products, groups, arrears, wards];
}
