import 'package:trash_pay/domain/entities/profile/profile.dart';

abstract class ProfileEvents {}

class LoadProfileEvent extends ProfileEvents {}

class UpdateProfileEvent extends ProfileEvents {
  final ProfileModel profile;
  UpdateProfileEvent(this.profile);
}

class UpdatePreferencesEvent extends ProfileEvents {
  final Map<String, dynamic> preferences;
  UpdatePreferencesEvent(this.preferences);
}

class ChangePasswordEvent extends ProfileEvents {
  final String currentPassword;
  final String newPassword;
  ChangePasswordEvent(this.currentPassword, this.newPassword);
}

class LogoutEvent extends ProfileEvents {} 