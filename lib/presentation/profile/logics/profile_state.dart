import 'package:trash_pay/domain/entities/profile/profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  ProfileLoaded(this.profile);
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  ProfileUpdateSuccess(this.message);
}

class PasswordChangeSuccess extends ProfileState {
  final String message;
  PasswordChangeSuccess(this.message);
}

class LogoutSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
} 