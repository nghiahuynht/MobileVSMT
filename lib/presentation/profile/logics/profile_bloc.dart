import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/profile/profile.dart';
import 'package:trash_pay/presentation/flash/logics/auth_bloc.dart';
import 'package:trash_pay/presentation/flash/logics/auth_events.dart';
import 'package:trash_pay/presentation/flash/logics/auth_state.dart';
import 'package:trash_pay/presentation/profile/logics/profile_events.dart';
import 'package:trash_pay/presentation/profile/logics/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvents, ProfileState> {
  ProfileBloc({AuthBloc? authBloc}) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_handleLoadProfile);
    on<UpdateProfileEvent>(_handleUpdateProfile);
    on<UpdatePreferencesEvent>(_handleUpdatePreferences);
    on<ChangePasswordEvent>(_handleChangePassword);
    on<LogoutEvent>(_handleLogout);
    
    _authBloc = authBloc;
    
    // Automatically load profile when bloc is created
    add(LoadProfileEvent());
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();
  AuthBloc? _authBloc;
  ProfileModel? _currentProfile;

  Future<void> _handleLoadProfile(
      LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Try to get user from AuthBloc first
      if (_authBloc != null) {
        final authState = _authBloc!.state;
        if (authState is Authenticated && authState.user != null) {
          _currentProfile = authState.user!.toProfileModel();
          emit(ProfileLoaded(_currentProfile!));
          return;
        }
      }
      
      // If AuthBloc doesn't have user info, try to get from domain manager
      final user = await domainManager.auth.getCurrentUser();
      if (user != null) {
        _currentProfile = user.toProfileModel();
        emit(ProfileLoaded(_currentProfile!));
      }
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
      // Call AuthBloc to handle logout
      if (_authBloc != null) {
        _authBloc!.add(SignOut());
      } else {
        // Fallback logout
        await domainManager.auth.signOut();
      }
      
      _currentProfile = null;
      emit(LogoutSuccess());
    } catch (e) {
      emit(ProfileError('Không thể đăng xuất: ${e.toString()}'));
    }
  }

  // Mock data generator - fallback when no user data available
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