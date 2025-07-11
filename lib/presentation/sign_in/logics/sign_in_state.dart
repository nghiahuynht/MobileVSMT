abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {
  final String uid;
  SignInSuccess(this.uid);
}

class SignInFailure extends SignInState {
  final String message;
  SignInFailure(this.message);
}
