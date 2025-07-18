import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/profile/profile.dart';
import 'package:trash_pay/presentation/profile/logics/profile_events.dart';
import 'package:trash_pay/presentation/profile/logics/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvents, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_handleLoadProfile);
    on<UpdateProfileEvent>(_handleUpdateProfile);
    on<UpdatePreferencesEvent>(_handleUpdatePreferences);
    on<ChangePasswordEvent>(_handleChangePassword);
    on<LogoutEvent>(_handleLogout);
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();
  ProfileModel? _currentProfile;

  Future<void> _handleLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Simulated data - replace with actual repository call
      _currentProfile = _generateMockProfile();
      emit(ProfileLoaded(_currentProfile!));
    } catch (e) {
      emit(ProfileError('Không thể tải thông tin hồ sơ: ${e.toString()}'));
    }
  }

  Future<void> _handleUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      // Simulated update - replace with actual repository call
      _currentProfile = event.profile;
      emit(ProfileUpdateSuccess('Đã cập nhật thông tin thành công'));
      emit(ProfileLoaded(_currentProfile!));
    } catch (e) {
      emit(ProfileError('Không thể cập nhật thông tin: ${e.toString()}'));
    }
  }

  Future<void> _handleUpdatePreferences(
      UpdatePreferencesEvent event, Emitter<ProfileState> emit) async {
    try {
      if (_currentProfile != null) {
        _currentProfile = _currentProfile!.copyWith(preferences: event.preferences);
        emit(ProfileUpdateSuccess('Đã cập nhật cài đặt'));
        emit(ProfileLoaded(_currentProfile!));
      }
    } catch (e) {
      emit(ProfileError('Không thể cập nhật cài đặt: ${e.toString()}'));
    }
  }

  Future<void> _handleChangePassword(
      ChangePasswordEvent event, Emitter<ProfileState> emit) async {
    try {
      // Simulated password change - replace with actual repository call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      emit(PasswordChangeSuccess('Đã thay đổi mật khẩu thành công'));
      if (_currentProfile != null) {
        emit(ProfileLoaded(_currentProfile!));
      }
    } catch (e) {
      emit(ProfileError('Không thể thay đổi mật khẩu: ${e.toString()}'));
    }
  }

  Future<void> _handleLogout(
      LogoutEvent event, Emitter<ProfileState> emit) async {
    try {
      // Simulated logout - replace with actual repository call
      await Future.delayed(const Duration(milliseconds: 500));
      _currentProfile = null;
      emit(LogoutSuccess());
    } catch (e) {
      emit(ProfileError('Không thể đăng xuất: ${e.toString()}'));
    }
  }

  // Mock data generator - replace with actual repository
  ProfileModel _generateMockProfile() {
    return ProfileModel(
      id: 'user_001',
      name: 'Nguyễn Văn Admin',
      email: 'admin@trashpay.com',
      phone: '0901234567',
      role: 'admin',
      department: 'Waste Management',
      joinedAt: DateTime.now().subtract(const Duration(days: 365)),
      isActive: true,
      preferences: {
        'notifications': true,
        'darkMode': false,
        'language': 'vi',
        'autoSync': true,
      },
    );
  }
} 