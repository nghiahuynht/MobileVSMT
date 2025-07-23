import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

/// Event để khởi tạo app
class AppInitialized extends AppEvent {}

/// Event để load lại areas sau khi đăng nhập
class LoadAreasAfterLogin extends AppEvent {}

/// Event để hiển thị loading cho toàn app
class ShowGlobalLoading extends AppEvent {
  final String? message;
  
  const ShowGlobalLoading({this.message});
  
  @override
  List<Object?> get props => [message];
}

/// Event để ẩn loading toàn app
class HideGlobalLoading extends AppEvent {}

/// Event để hiển thị thông báo toàn app
class ShowAppMessage extends AppEvent {
  final String message;
  final AppMessageType type;
  final Duration? duration;
  
  const ShowAppMessage({
    required this.message,
    this.type = AppMessageType.info,
    this.duration,
  });
  
  @override
  List<Object?> get props => [message, type, duration];
}

/// Event để ẩn thông báo
class HideAppMessage extends AppEvent {}

/// Event để thay đổi theme
class ChangeTheme extends AppEvent {
  final bool isDarkMode;
  
  const ChangeTheme(this.isDarkMode);
  
  @override
  List<Object?> get props => [isDarkMode];
}

/// Event để thay đổi ngôn ngữ
class ChangeLanguage extends AppEvent {
  final String languageCode;
  
  const ChangeLanguage(this.languageCode);
  
  @override
  List<Object?> get props => [languageCode];
}

/// Event để cập nhật trạng thái mạng
class UpdateNetworkStatus extends AppEvent {
  final bool isConnected;
  
  const UpdateNetworkStatus(this.isConnected);
  
  @override
  List<Object?> get props => [isConnected];
}

/// Event để cập nhật cấu hình app
class UpdateAppConfig extends AppEvent {
  final Map<String, dynamic> config;
  
  const UpdateAppConfig(this.config);
  
  @override
  List<Object?> get props => [config];
}

/// Event để reset app state
class ResetAppState extends AppEvent {}

/// Event để load master data
class LoadMasterData extends AppEvent {
  final bool forceRefresh;
  
  const LoadMasterData({this.forceRefresh = false});
  
  @override
  List<Object?> get props => [forceRefresh];
}

/// Event để load specific master data
class LoadSpecificMasterData extends AppEvent {
  final MasterDataType type;
  final bool forceRefresh;
  
  const LoadSpecificMasterData({
    required this.type,
    this.forceRefresh = false,
  });
  
  @override
  List<Object?> get props => [type, forceRefresh];
}

/// Event để clear master data cache
class ClearMasterDataCache extends AppEvent {
  final MasterDataType? type; // null = clear all
  
  const ClearMasterDataCache({this.type});
  
  @override
  List<Object?> get props => [type];
}

/// Enum để định nghĩa loại message
enum AppMessageType {
  success,
  error,
  warning,
  info,
}

/// Enum cho các loại master data
enum MasterDataType {
  units,
  groups,
  areas,
  wards,
}