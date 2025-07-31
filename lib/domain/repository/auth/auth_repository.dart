import 'package:trash_pay/domain/entities/sign_in/sign_in_response.dart';
import 'package:trash_pay/domain/entities/user/user.dart';

abstract class AuthRepository {
  Future<SignInResponse?> signInWithLoginName({required String loginName, required String password, required String companyCode, required String companyName});
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();
}
