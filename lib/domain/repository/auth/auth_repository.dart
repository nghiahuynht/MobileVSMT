import 'package:trash_pay/domain/entities/user/user.dart';

abstract class AuthRepository {
  Future<UserModel?> signInWithEmail(String email, String password);
  UserModel? getCurrentUser();
  Future<void> signOut();
}
