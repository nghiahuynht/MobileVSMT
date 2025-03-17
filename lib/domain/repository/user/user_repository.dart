import 'dart:async';

import '../../entity/user/login_params.dart';
import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<User?> login(LoginParams params);

  Future<void> saveIsLoggedIn(bool value);

  Future<bool> get isLoggedIn;
}
