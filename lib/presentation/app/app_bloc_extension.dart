import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/unit/unit.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/domain/entities/language/language.dart';
import 'logics/app_bloc.dart';
import 'logics/app_events.dart';
import 'logics/app_state.dart';
import 'master_data_manager.dart';

/// Extension để dễ dàng truy cập AppBloc từ BuildContext
extension AppBlocExtension on BuildContext {
  AppBloc get appBloc => read<AppBloc>();

  /// Hiển thị loading toàn app
  void showAppLoading([String? message]) {
    appBloc.showLoading(message);
  }

  /// Ẩn loading toàn app
  void hideAppLoading() {
    appBloc.hideLoading();
  }

  /// Hiển thị thông báo thành công
  void showAppSuccess(String message, {Duration? duration}) {
    appBloc.showSuccess(message, duration: duration);
  }

  /// Hiển thị thông báo lỗi
  void showAppError(String message, {Duration? duration}) {
    appBloc.showError(message, duration: duration);
  }

  /// Hiển thị thông báo cảnh báo
  void showAppWarning(String message, {Duration? duration}) {
    appBloc.showWarning(message, duration: duration);
  }

  /// Hiển thị thông báo thông tin
  void showAppInfo(String message, {Duration? duration}) {
    appBloc.showInfo(message, duration: duration);
  }

  /// Toggle theme
  void toggleAppTheme() {
    appBloc.toggleTheme();
  }

  /// Thay đổi ngôn ngữ
  void changeAppLanguage(String languageCode) {
    appBloc.setLanguage(languageCode);
  }

  /// Cập nhật network status
  void updateNetworkStatus(bool isConnected) {
    appBloc.setNetworkStatus(isConnected);
  }

  /// Cập nhật app config
  void updateAppConfig(String key, dynamic value) {
    appBloc.updateConfig(key, value);
  }

  /// Load all master data
  void loadAllMasterData({bool forceRefresh = false}) {
    appBloc.loadAllMasterData(forceRefresh: forceRefresh);
  }

  /// Load specific master data type
  void loadMasterDataType(MasterDataType type, {bool forceRefresh = false}) {
    appBloc.loadMasterDataType(type, forceRefresh: forceRefresh);
  }

  /// Clear master data cache
  void clearMasterData([MasterDataType? type]) {
    appBloc.clearMasterData(type);
  }
}

/// Extension để truy cập master data từ AppBloc state
extension AppBlocMasterDataExtension on BuildContext {
  /// Get master data cache
  MasterDataCache get masterDataCache => 
      read<AppBloc>().state.masterDataCache;

  /// Get Units
  List<Unit> get units => masterDataCache.units;

  /// Get Products  
  List<ProductModel> get products => masterDataCache.products;

  /// Get Customers
  List<CustomerModel> get customers => masterDataCache.customers;

  /// Get Groups
  List<Group> get groups => masterDataCache.groups;

  /// Get Areas
  List<Area> get areas => masterDataCache.areas;

  /// Get Wards
  List<Ward> get wards => masterDataCache.wards;

  /// Get Languages
  List<Language> get languages => masterDataCache.languages;

  /// Check if master data is loaded
  bool isMasterDataLoaded(MasterDataType type) =>
      masterDataCache.isDataLoaded(type);

  /// Check if master data is loading
  bool isMasterDataLoading(MasterDataType type) =>
      masterDataCache.isLoading(type);

  /// Check if master data needs refresh
  bool needsMasterDataRefresh(MasterDataType type) =>
      masterDataCache.needsRefresh(type);

  /// Utility methods với master data manager
  
  /// Lọc Groups theo Ward ID
  List<Group> getGroupsByWardId(int wardId) {
    final manager = MasterDataManager();
    return manager.getGroupsByWardId(groups, wardId);
  }

  /// Lọc Areas theo Group ID
  List<Area> getAreasByGroupId(int groupId) {
    final manager = MasterDataManager();
    return manager.getAreasByGroupId(areas, groupId);
  }

  /// Lọc Customers theo Group Code
  List<CustomerModel> getCustomersByGroupCode(String groupCode) {
    final manager = MasterDataManager();
    return manager.getCustomersByGroupCode(customers, groupCode);
  }

  /// Lọc Products active
  List<ProductModel> getActiveProducts() {
    final manager = MasterDataManager();
    return manager.getActiveProducts(products);
  }

  /// Tìm Unit theo code
  Unit? findUnitByCode(String code) {
    final manager = MasterDataManager();
    return manager.findUnitByCode(units, code);
  }

  /// Tìm Product theo code
  ProductModel? findProductByCode(String code) {
    final manager = MasterDataManager();
    return manager.findProductByCode(products, code);
  }

  /// Tìm Customer theo code
  CustomerModel? findCustomerByCode(String code) {
    final manager = MasterDataManager();
    return manager.findCustomerByCode(customers, code);
  }

  /// Tìm Group theo code
  Group? findGroupByCode(String code) {
    final manager = MasterDataManager();
    return manager.findGroupByCode(groups, code);
  }

  /// Tìm Area theo code
  Area? findAreaByCode(String code) {
    final manager = MasterDataManager();
    return manager.findAreaByCode(areas, code);
  }

  /// Tìm Ward theo code
  Ward? findWardByCode(String code) {
    final manager = MasterDataManager();
    return manager.findWardByCode(wards, code);
  }
}

/// Extension cho thực hiện các tác vụ async với loading
extension AppBlocAsyncExtension on BuildContext {
  /// Thực hiện async task với loading
  Future<T?> runWithLoading<T>(
    Future<T> Function() task, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool showSuccess = false,
  }) async {
    try {
      showAppLoading(loadingMessage);
      final result = await task();
      hideAppLoading();
      
      if (showSuccess && successMessage != null) {
        showAppSuccess(successMessage);
      }
      
      return result;
    } catch (e) {
      hideAppLoading();
      showAppError(errorMessage ?? 'Có lỗi xảy ra: $e');
      return null;
    }
  }

  /// Thực hiện async task với error handling
  Future<T?> runSafely<T>(
    Future<T> Function() task, {
    String? errorMessage,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await task();
    } catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        showAppError(errorMessage ?? 'Có lỗi xảy ra: $e');
      }
      return null;
    }
  }
} 