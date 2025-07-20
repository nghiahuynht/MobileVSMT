import 'package:equatable/equatable.dart';
import 'package:trash_pay/domain/entities/user/user.dart';

class AuthState extends Equatable {
  final UserModel? user;

  const AuthState({this.user});

  @override
  List<Object?> get props => [user];
}

class Authenticated extends AuthState {
  final UserModel? user;
  const Authenticated({this.user});
}

class Unauthenticated extends AuthState {}

class AuthLoading extends AuthState {}
