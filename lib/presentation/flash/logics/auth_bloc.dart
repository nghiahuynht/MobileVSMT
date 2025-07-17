import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/presentation/flash/logics/auth_events.dart';
import 'package:trash_pay/presentation/flash/logics/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState()) {
    on<CheckAuthStatus>((event, emit) {
      // final user = domainManager.auth.getCurrentUser();

      // if (user != null) {
      //   emit(Authenticated(user));
      // } else {
      //   emit(Unauthenticated());
      // }
    });
  }

  final DomainManager domainManager = DomainManager();
}
