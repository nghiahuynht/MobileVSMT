abstract class SignInEvent {}

class SignInEmailEvent extends SignInEvent {
  final String email;
  final String password;
  SignInEmailEvent(this.email, this.password);
}

class SignInGoogleEvent extends SignInEvent {}

class SignInAppleEvent extends SignInEvent {}

class SignOutEvent extends SignInEvent {}
