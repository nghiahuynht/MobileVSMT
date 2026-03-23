abstract class SignInEvent {}

class LoadUnitsEvent extends SignInEvent {}

class SignInWithLoginNameEvent extends SignInEvent {
  final String loginName;
  final String password;
  final String companyCode;
  final String companyName;
  final String? linkTraCuu;
  final String? address;
  SignInWithLoginNameEvent(this.loginName, this.password, this.companyCode, this.companyName, {this.linkTraCuu, this.address});
}



