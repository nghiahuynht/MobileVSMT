import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/unit/unit.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/services/user_prefs.dart';
import '../master_data_manager.dart';
import 'app_events.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final UserPrefs _userPrefs = UserPrefs.I;
  final MasterDataManager _masterDataManager = MasterDataManager();
  Timer? _messageTimer;

  AppBloc() : super(AppState.initial()) {
    on<AppInitialized>(_onAppInitialized);
    on<ShowGlobalLoading>(_onShowGlobalLoading);
    on<HideGlobalLoading>(_onHideGlobalLoading);
    on<ShowAppMessage>(_onShowAppMessage);
    on<HideAppMessage>(_onHideAppMessage);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLanguage>(_onChangeLanguage);
    on<UpdateNetworkStatus>(_onUpdateNetworkStatus);
    on<UpdateAppConfig>(_onUpdateAppConfig);
    on<ResetAppState>(_onResetAppState);
    on<LoadMasterData>(_onLoadMasterData);
    on<LoadSpecificMasterData>(_onLoadSpecificMasterData);
    on<ClearMasterDataCache>(_onClearMasterDataCache);

    // Auto initialize app
    add(AppInitialized());
  }

  @override
  Future<void> close() {
    _messageTimer?.cancel();
    return super.close();
  }

  /// Khởi tạo app và load preferences
  Future<void> _onAppInitialized(
    AppInitialized event,
    Emitter<AppState> emit,
  ) async {
    try {
      // Load saved preferences
      final themeMode = _userPrefs.getTheme();
      final isDarkMode = themeMode == ThemeMode.dark;

      // Default network status to true (sẽ cập nhật sau nếu cần)
      const isConnected = true;

      emit(state.copyWith(
        isInitialized: true,
        isDarkMode: isDarkMode,
        languageCode: 'vi', // Default language
        isNetworkConnected: isConnected,
      ));

      // Auto load master data after app initialization
      add(const LoadMasterData());
    } catch (e) {
      // Log error but don't fail initialization
      emit(state.copyWith(
        isInitialized: true,
        currentMessage: AppMessage.error('Lỗi khởi tạo ứng dụng: $e'),
      ));
    }
  }

  /// Hiển thị loading toàn app
  void _onShowGlobalLoading(
    ShowGlobalLoading event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(
      isGlobalLoading: true,
      globalLoadingMessage: event.message,
    ));
  }

  /// Ẩn loading toàn app
  void _onHideGlobalLoading(
    HideGlobalLoading event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(
      isGlobalLoading: false,
      clearLoadingMessage: true,
    ));
  }

  /// Hiển thị thông báo
  void _onShowAppMessage(
    ShowAppMessage event,
    Emitter<AppState> emit,
  ) {
    // Cancel previous timer if exists
    _messageTimer?.cancel();

    final message = AppMessage(
      message: event.message,
      type: event.type,
      duration: event.duration,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(currentMessage: message));

    // Auto hide message after duration
    final duration = event.duration ?? const Duration(seconds: 3);
    _messageTimer = Timer(duration, () {
      add(HideAppMessage());
    });
  }

  /// Ẩn thông báo
  void _onHideAppMessage(
    HideAppMessage event,
    Emitter<AppState> emit,
  ) {
    _messageTimer?.cancel();
    emit(state.copyWith(clearMessage: true));
  }

  /// Thay đổi theme
  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<AppState> emit,
  ) async {
    try {
      final themeMode = event.isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _userPrefs.setTheme(themeMode);
      emit(state.copyWith(isDarkMode: event.isDarkMode));
    } catch (e) {
      add(ShowAppMessage(
        message: 'Lỗi khi thay đổi theme: $e',
        type: AppMessageType.error,
      ));
    }
  }

  /// Thay đổi ngôn ngữ
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<AppState> emit,
  ) async {
    try {
      // Note: UserPrefs không có setLanguageCode, sẽ cần thêm vào sau
      emit(state.copyWith(languageCode: event.languageCode));
    } catch (e) {
      add(ShowAppMessage(
        message: 'Lỗi khi thay đổi ngôn ngữ: $e',
        type: AppMessageType.error,
      ));
    }
  }

  /// Cập nhật trạng thái mạng
  void _onUpdateNetworkStatus(
    UpdateNetworkStatus event,
    Emitter<AppState> emit,
  ) {
    if (state.isNetworkConnected != event.isConnected) {
      emit(state.copyWith(isNetworkConnected: event.isConnected));

      // Show message về network status
      if (event.isConnected) {
        add(const ShowAppMessage(
          message: 'Đã kết nối mạng',
          type: AppMessageType.success,
          duration: Duration(seconds: 2),
        ));
      } else {
        add(const ShowAppMessage(
          message: 'Mất kết nối mạng',
          type: AppMessageType.warning,
          duration: Duration(seconds: 5),
        ));
      }
    }
  }

  /// Cập nhật cấu hình app
  void _onUpdateAppConfig(
    UpdateAppConfig event,
    Emitter<AppState> emit,
  ) {
    final newConfig = Map<String, dynamic>.from(state.config);
    newConfig.addAll(event.config);
    emit(state.copyWith(config: newConfig));
  }

  /// Reset app state
  void _onResetAppState(
    ResetAppState event,
    Emitter<AppState> emit,
  ) {
    _messageTimer?.cancel();
    emit(AppState.initial());
    add(AppInitialized());
  }

  /// Các utility methods để dễ sử dụng
  void showLoading([String? message]) {
    add(ShowGlobalLoading(message: message));
  }

  void hideLoading() {
    add(HideGlobalLoading());
  }

  void showSuccess(String message, {Duration? duration}) {
    add(ShowAppMessage(
      message: message,
      type: AppMessageType.success,
      duration: duration,
    ));
  }

  void showError(String message, {Duration? duration}) {
    add(ShowAppMessage(
      message: message,
      type: AppMessageType.error,
      duration: duration,
    ));
  }

  void showWarning(String message, {Duration? duration}) {
    add(ShowAppMessage(
      message: message,
      type: AppMessageType.warning,
      duration: duration,
    ));
  }

  void showInfo(String message, {Duration? duration}) {
    add(ShowAppMessage(
      message: message,
      type: AppMessageType.info,
      duration: duration,
    ));
  }

  void toggleTheme() {
    add(ChangeTheme(!state.isDarkMode));
  }

  void setLanguage(String languageCode) {
    add(ChangeLanguage(languageCode));
  }

  void updateConfig(String key, dynamic value) {
    add(UpdateAppConfig({key: value}));
  }

  void setNetworkStatus(bool isConnected) {
    add(UpdateNetworkStatus(isConnected));
  }

  /// Master Data Events Handlers

  /// Load all master data
  Future<void> _onLoadMasterData(
    LoadMasterData event,
    Emitter<AppState> emit,
  ) async {
    try {
      final currentCache = state.masterDataCache;

      // Check if we need to load (first time or force refresh)
      if (!event.forceRefresh && _allDataLoaded(currentCache)) {
        return; // Data already loaded and not forcing refresh
      }

      // Set loading states
      var newCache = currentCache;
      for (final type in MasterDataType.values) {
        newCache = newCache.setLoading(type, true);
      }
      emit(state.copyWith(masterDataCache: newCache));

      // Load all data
      final results = await _masterDataManager.loadAllMasterData();

      // Update cache with loaded data
      newCache = _updateCacheWithResults(newCache, results);

      // Mark all as loaded
      for (final type in MasterDataType.values) {
        newCache = newCache.setDataLoaded(type);
      }

      emit(state.copyWith(masterDataCache: newCache));
    } catch (e) {
      // Reset loading states on error
      var newCache = state.masterDataCache;
      for (final type in MasterDataType.values) {
        newCache = newCache.setLoading(type, false);
      }
      emit(state.copyWith(masterDataCache: newCache));

      add(ShowAppMessage(
        message: 'Lỗi khi load master data: $e',
        type: AppMessageType.error,
      ));
    }
  }

  /// Load specific master data type
  Future<void> _onLoadSpecificMasterData(
    LoadSpecificMasterData event,
    Emitter<AppState> emit,
  ) async {
    try {
      final currentCache = state.masterDataCache;

      // Check if we need to load
      if (!event.forceRefresh &&
          currentCache.isDataLoaded(event.type) &&
          !currentCache.needsRefresh(event.type)) {
        return; // Data already loaded and fresh
      }

      // Set loading state
      var newCache = currentCache.setLoading(event.type, true);
      emit(state.copyWith(masterDataCache: newCache));

      // // Load specific data
      // final data = await _masterDataManager.loadMasterDataByType(event.type);

      // // Update cache with loaded data
      // newCache = _updateCacheWithSingleType(newCache, event.type, data);
      // newCache = newCache.setDataLoaded(event.type);

      // emit(state.copyWith(masterDataCache: newCache));
    } catch (e) {
      // Reset loading state on error
      var newCache = state.masterDataCache.setLoading(event.type, false);
      emit(state.copyWith(masterDataCache: newCache));

      add(ShowAppMessage(
        message: 'Lỗi khi load ${event.type.name}: $e',
        type: AppMessageType.error,
      ));
    }
  }

  /// Clear master data cache
  void _onClearMasterDataCache(
    ClearMasterDataCache event,
    Emitter<AppState> emit,
  ) {
    var newCache = state.masterDataCache;

    if (event.type != null) {
      // Clear specific type
      newCache = newCache.clearDataType(event.type!);
    } else {
      // Clear all
      newCache = newCache.clearAll();
    }

    emit(state.copyWith(masterDataCache: newCache));
  }

  /// Helper methods for master data

  bool _allDataLoaded(MasterDataCache cache) {
    for (final type in MasterDataType.values) {
      if (!cache.isDataLoaded(type) || cache.needsRefresh(type)) {
        return false;
      }
    }
    return true;
  }

  MasterDataCache _updateCacheWithResults(
    MasterDataCache cache,
    Map<MasterDataType, List<dynamic>> results,
  ) {
    var newCache = cache;

    for (final entry in results.entries) {
      newCache = _updateCacheWithSingleType(newCache, entry.key, entry.value);
    }

    return newCache;
  }

  MasterDataCache _updateCacheWithSingleType(
    MasterDataCache cache,
    MasterDataType type,
    List<dynamic> data,
  ) {
    switch (type) {
      case MasterDataType.units:
        return cache.copyWith(units: data.cast<Unit>());
      case MasterDataType.groups:
        return cache.copyWith(groups: data.cast<Group>());
      case MasterDataType.areas:
        return cache.copyWith(areas: data.cast<Area>());
      case MasterDataType.wards:
        return cache.copyWith(wards: data.cast<Ward>());
    }
  }

  /// Public utility methods for master data

  void loadAllMasterData({bool forceRefresh = false}) {
    add(LoadMasterData(forceRefresh: forceRefresh));
  }

  void loadMasterDataType(MasterDataType type, {bool forceRefresh = false}) {
    add(LoadSpecificMasterData(type: type, forceRefresh: forceRefresh));
  }

  void clearMasterData([MasterDataType? type]) {
    add(ClearMasterDataCache(type: type));
  }
}
