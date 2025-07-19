import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/repository/auth/auth_repository.dart';
import 'package:trash_pay/presentation/flash/logics/auth_events.dart';
import 'package:trash_pay/presentation/flash/logics/auth_state.dart';
import 'package:trash_pay/services/user_prefs.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final DomainManager _domainManager = DomainManager();

  AuthBloc({required AuthRepository authRepository}) : super(AuthLoading()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignOut>(_onSignOut);
  }

  final userPrefs = UserPrefs.I;

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final token = userPrefs.getToken();

      if (token != null) {
        final user = await _domainManager.auth.getCurrentUser();
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void _onSignOut(SignOut event, Emitter<AuthState> emit) {
    userPrefs.setToken(null);
    userPrefs.setCompany(null);
    userPrefs.setLoginName(null);
    userPrefs.setPassword(null);
    emit(Unauthenticated());
  }
}
