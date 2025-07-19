import 'package:trash_pay/domain/entities/unit/unit.dart';

abstract class SignInState {}

class SignInInitial extends SignInState {}

class UnitsLoading extends SignInState {}

class UnitsLoaded extends SignInState {
  final List<Unit> units;
  UnitsLoaded(this.units);
}

class UnitsError extends SignInState {
  final String message;
  UnitsError(this.message);
}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {
  SignInSuccess();
}

class SignInFailure extends SignInState {
  final String message;
  SignInFailure(this.message);
}
