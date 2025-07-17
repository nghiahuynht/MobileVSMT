import 'package:trash_pay/domain/repository/auth/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // final FirebaseAuthService authService = FirebaseAuthService();

  // AuthRepositoryImpl();

  // @override
  // Future<UserModel?> signInWithEmail(String email, String password) async {
  //   final firebaseUser = await authService.signInWithEmail(email, password);
  //   return _mapFirebaseUserToUserModel(firebaseUser);
  // }

  // @override
  // Future<UserModel?> signInWithApple() async {
  //   final firebaseUser = await authService.signInWithApple();
  //   return _mapFirebaseUserToUserModel(firebaseUser);
  // }

  // // @override
  // // Future<UserModel?> signInWithGoogle() async {
  // //   final firebaseUser = await authService.signInWithGoogle();
  // //   return _mapFirebaseUserToUserModel(firebaseUser);
  // // }

  // @override
  // Future<void> signOut() async {
  //   return authService.signOut();
  // }

  // @override
  // UserModel? getCurrentUser() {
  //   final firebaseUser = authService.getCurrentUser();
  //   return _mapFirebaseUserToUserModel(firebaseUser);
  // }

  // UserModel _mapFirebaseUserToUserModel(User? user) {
  //   if (user == null) throw Exception('No user found');
  //   return UserModel(
  //     uid: user.uid,
  //     email: user.email,
  //     name: user.displayName,
  //     photoUrl: user.photoURL,
  //   );
  // }
}
