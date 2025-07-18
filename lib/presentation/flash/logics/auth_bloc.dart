import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/presentation/flash/logics/auth_events.dart';
import 'package:trash_pay/presentation/flash/logics/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthLoading()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final user = domainManager.auth.getCurrentUser();
      
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
