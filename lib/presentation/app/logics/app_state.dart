import 'package:equatable/equatable.dart';
import 'package:trash_pay/domain/entities/unit/unit.dart';
import 'package:trash_pay/domain/entities/product/product.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/location/group.dart';
import 'package:trash_pay/domain/entities/location/area.dart';
import 'package:trash_pay/domain/entities/location/ward.dart';
import 'package:trash_pay/domain/entities/language/language.dart';
import 'app_events.dart';

class AppState extends Equatable {
  final bool isInitialized;
  final bool isGlobalLoading;
  final String? globalLoadingMessage;
  final AppMessage? currentMessage;
  final bool isDarkMode;
  final String languageCode;
  final bool isNetworkConnected;
  final Map<String, dynamic> config;
  final DateTime lastUpdated;
  
  // Master data cache
  final MasterDataCache masterDataCache;

  const AppState({
    this.isInitialized = false,
    this.isGlobalLoading = false,
    this.globalLoadingMessage,
    this.currentMessage,
    this.isDarkMode = false,
    this.languageCode = 'vi',
    this.isNetworkConnected = true,
    this.config = const {},
    required this.lastUpdated,
    this.masterDataCache = const MasterDataCache(),
  });

  /// Initial state của app
  factory AppState.initial() {
    return AppState(
      lastUpdated: DateTime.now(),
      masterDataCache: MasterDataCache.empty(),
    );
  }

  /// Copy with method để tạo state mới
  AppState copyWith({
    bool? isInitialized,
    bool? isGlobalLoading,
    String? globalLoadingMessage,
    AppMessage? currentMessage,
    bool? isDarkMode,
    String? languageCode,
    bool? isNetworkConnected,
    Map<String, dynamic>? config,
    MasterDataCache? masterDataCache,
    bool clearMessage = false,
    bool clearLoadingMessage = false,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isGlobalLoading: isGlobalLoading ?? this.isGlobalLoading,
      globalLoadingMessage: clearLoadingMessage ? null : (globalLoadingMessage ?? this.globalLoadingMessage),
      currentMessage: clearMessage ? null : (currentMessage ?? this.currentMessage),
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
      config: config ?? this.config,
      masterDataCache: masterDataCache ?? this.masterDataCache,
      lastUpdated: DateTime.now(),
    );
  }

  /// Các getter tiện ích
  bool get hasMessage => currentMessage != null;
  bool get hasGlobalLoading => isGlobalLoading;
  bool get isOnline => isNetworkConnected;
  bool get isOffline => !isNetworkConnected;

  @override
  List<Object?> get props => [
        isInitialized,
        isGlobalLoading,
        globalLoadingMessage,
        currentMessage,
        isDarkMode,
        languageCode,
        isNetworkConnected,
        config,
        masterDataCache,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'AppState(isInitialized: $isInitialized, isGlobalLoading: $isGlobalLoading, isDarkMode: $isDarkMode, languageCode: $languageCode, isNetworkConnected: $isNetworkConnected)';
  }
}

/// Class để đại diện cho app message
class AppMessage extends Equatable {
  final String message;
  final AppMessageType type;
  final Duration? duration;
  final DateTime timestamp;

  const AppMessage({
    required this.message,
    required this.type,
    this.duration,
    required this.timestamp,
  });

  factory AppMessage.success(String message, {Duration? duration}) {
    return AppMessage(
      message: message,
      type: AppMessageType.success,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  factory AppMessage.error(String message, {Duration? duration}) {
    return AppMessage(
      message: message,
      type: AppMessageType.error,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  factory AppMessage.warning(String message, {Duration? duration}) {
    return AppMessage(
      message: message,
      type: AppMessageType.warning,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  factory AppMessage.info(String message, {Duration? duration}) {
    return AppMessage(
      message: message,
      type: AppMessageType.info,
      duration: duration,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [message, type, duration, timestamp];

  @override
  String toString() {
    return 'AppMessage(message: $message, type: $type, duration: $duration)';
  }
}

/// Class để cache master data
class MasterDataCache extends Equatable {
  final List<Unit> units;
  final List<ProductModel> products;
  final List<CustomerModel> customers;
  final List<Group> groups;
  final List<Area> areas;
  final List<Ward> wards;
  final List<Language> languages;
  
  final Map<MasterDataType, DateTime> lastLoadedTimes;
  final Map<MasterDataType, bool> loadingStates;

  const MasterDataCache({
    this.units = const [],
    this.products = const [],
    this.customers = const [],
    this.groups = const [],
    this.areas = const [],
    this.wards = const [],
    this.languages = const [],
    this.lastLoadedTimes = const {},
    this.loadingStates = const {},
  });

  factory MasterDataCache.empty() {
    return const MasterDataCache();
  }

  MasterDataCache copyWith({
    List<Unit>? units,
    List<ProductModel>? products,
    List<CustomerModel>? customers,
    List<Group>? groups,
    List<Area>? areas,
    List<Ward>? wards,
    List<Language>? languages,
    Map<MasterDataType, DateTime>? lastLoadedTimes,
    Map<MasterDataType, bool>? loadingStates,
  }) {
    return MasterDataCache(
      units: units ?? this.units,
      products: products ?? this.products,
      customers: customers ?? this.customers,
      groups: groups ?? this.groups,
      areas: areas ?? this.areas,
      wards: wards ?? this.wards,
      languages: languages ?? this.languages,
      lastLoadedTimes: lastLoadedTimes ?? this.lastLoadedTimes,
      loadingStates: loadingStates ?? this.loadingStates,
    );
  }

  /// Kiểm tra data đã được load chưa
  bool isDataLoaded(MasterDataType type) {
    return lastLoadedTimes.containsKey(type);
  }

  /// Kiểm tra data có đang loading không
  bool isLoading(MasterDataType type) {
    return loadingStates[type] ?? false;
  }

  /// Kiểm tra data có cần refresh không (sau 1 giờ)
  bool needsRefresh(MasterDataType type) {
    final lastLoaded = lastLoadedTimes[type];
    if (lastLoaded == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastLoaded);
    return difference.inHours >= 1; // Refresh sau 1 giờ
  }

  /// Set loading state
  MasterDataCache setLoading(MasterDataType type, bool isLoading) {
    final newLoadingStates = Map<MasterDataType, bool>.from(loadingStates);
    newLoadingStates[type] = isLoading;
    return copyWith(loadingStates: newLoadingStates);
  }

  /// Set data loaded
  MasterDataCache setDataLoaded(MasterDataType type) {
    final newLastLoadedTimes = Map<MasterDataType, DateTime>.from(lastLoadedTimes);
    final newLoadingStates = Map<MasterDataType, bool>.from(loadingStates);
    
    newLastLoadedTimes[type] = DateTime.now();
    newLoadingStates[type] = false;
    
    return copyWith(
      lastLoadedTimes: newLastLoadedTimes,
      loadingStates: newLoadingStates,
    );
  }

  /// Clear specific data type
  MasterDataCache clearDataType(MasterDataType type) {
    final newLastLoadedTimes = Map<MasterDataType, DateTime>.from(lastLoadedTimes);
    final newLoadingStates = Map<MasterDataType, bool>.from(loadingStates);
    
    newLastLoadedTimes.remove(type);
    newLoadingStates.remove(type);

    switch (type) {
      case MasterDataType.units:
        return copyWith(
          units: [],
          lastLoadedTimes: newLastLoadedTimes,
          loadingStates: newLoadingStates,
        );
      case MasterDataType.groups:
        return copyWith(
          groups: [],
          lastLoadedTimes: newLastLoadedTimes,
          loadingStates: newLoadingStates,
        );
      case MasterDataType.areas:
        return copyWith(
          areas: [],
          lastLoadedTimes: newLastLoadedTimes,
          loadingStates: newLoadingStates,
        );
      case MasterDataType.wards:
        return copyWith(
          wards: [],
          lastLoadedTimes: newLastLoadedTimes,
          loadingStates: newLoadingStates,
        );
    }
  }

  /// Clear all data
  MasterDataCache clearAll() {
    return MasterDataCache.empty();
  }

  @override
  List<Object?> get props => [
        units,
        products,
        customers,
        groups,
        areas,
        wards,
        languages,
        lastLoadedTimes,
        loadingStates,
      ];

  @override
  String toString() {
    return 'MasterDataCache(units: ${units.length}, products: ${products.length}, customers: ${customers.length}, groups: ${groups.length}, areas: ${areas.length}, wards: ${wards.length}, languages: ${languages.length})';
  }
} 