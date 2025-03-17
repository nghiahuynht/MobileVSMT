import 'package:flutter_boilerplate/domain/entity/user/user.dart';
import 'package:flutter_boilerplate/domain/repository/user/user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  @override
  // TODO: implement isLoggedIn
  Future<bool> get isLoggedIn => throw UnimplementedError();

  @override
  Future<User?> login(params) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<void> saveIsLoggedIn(bool value) {
    // TODO: implement saveIsLoggedIn
    throw UnimplementedError();
  }
}
