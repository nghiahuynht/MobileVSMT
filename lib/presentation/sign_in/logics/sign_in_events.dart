abstract class SignInEvent {}

class LoadUnitsEvent extends SignInEvent {}

class SignInWithLoginNameEvent extends SignInEvent {
  final String loginName;
  final String password;
  final String companyCode;
  final String companyName;
  SignInWithLoginNameEvent(this.loginName, this.password, this.companyCode, this.companyName);
}



