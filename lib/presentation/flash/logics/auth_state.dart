import 'package:trash_pay/domain/entities/user/user.dart';

class AuthState {}

class Authenticated extends AuthState {
  final UserModel? user;
  Authenticated({this.user});
}

class Unauthenticated extends AuthState {}

class AuthLoading extends AuthState {}
