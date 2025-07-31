import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/meta_data/area.dart';
import 'package:trash_pay/domain/entities/meta_data/arrear.dart';
import 'package:trash_pay/domain/entities/meta_data/meta_data.dart';
import 'package:trash_pay/domain/entities/meta_data/payment_type.dart';
import 'package:trash_pay/domain/entities/meta_data/ward.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/services/token_manager.dart';
import 'app_events.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final DomainManager _domainManager = DomainManager();
  final TokenManager _tokenManager = TokenManager.instance;

  AppBloc() : super(AppState.initial()) {
    on<AppInitialized>(_onAppInitialized);
    on<LoadAreasAfterLogin>(_onLoadAreasAfterLogin);
  }

  Future<void> _onAppInitialized(
    AppInitialized event,
    Emitter<AppState> emit,
  ) async {
    try {

      

      if (_tokenManager.isLoggedIn) {
        final user = await _domainManager.auth.getCurrentUser();

        if (user != null) {
          final [areas, products, metaData] = await Future.wait([
            _domainManager.metaData.getAreas(saleUser: user.code),
            _domainManager.metaData.getAllProduct(),
            _domainManager.metaData.getAllMetaData()
          ]);

          final provinces = (metaData as MetaData).provinces;
          final groups = metaData.businessTypes;
          final arrears = metaData.arrears;
          final wards = metaData.wards;
          final paymentTypes = metaData.paymentTypes;

          emit(state.copyWith(
              areas: areas as List<Area>?,
              provinces: provinces,
              groups: groups as List<Group>,
              products: products as List<ProductModel>?,
              arrears: arrears as List<Arrear>,
              wards: wards as List<Ward>,
              paymentTypes: paymentTypes as List<PaymentType>,
              isInitialized: true,
              userCode: user.code));
        } else {
          emit(state.copyWith(isInitialized: true));
        }
      } else {
        emit(state.copyWith(isInitialized: true));
      }
    } catch (e) {
      emit(state.copyWith(isInitialized: true));
    }
  }

  Future<void> _onLoadAreasAfterLogin(
    LoadAreasAfterLogin event,
    Emitter<AppState> emit,
  ) async {
    try {
      if (_tokenManager.isLoggedIn) {
        final user = await _domainManager.auth.getCurrentUser();

        if (user != null) {
          final [areas, products, metaData] = await Future.wait([
            _domainManager.metaData.getAreas(saleUser: user.code),
            _domainManager.metaData.getAllProduct(),
            _domainManager.metaData.getAllMetaData()
          ]);

          final provinces = (metaData as MetaData).provinces;
          final groups = metaData.businessTypes;
          final arrears = metaData.arrears;
          final wards = metaData.wards;
          final paymentTypes = metaData.paymentTypes;

          emit(state.copyWith(
              areas: areas as List<Area>?,
              provinces: provinces,
              groups: groups as List<Group>,
              products: products as List<ProductModel>?,
              arrears: arrears as List<Arrear>,
              wards: wards as List<Ward>,
              paymentTypes: paymentTypes as List<PaymentType>,
              isInitialized: true,
              userCode: user.code));
        }
      }
    } catch (e) {
      emit(state.copyWith(isInitialized: true));
    }
  }
}
