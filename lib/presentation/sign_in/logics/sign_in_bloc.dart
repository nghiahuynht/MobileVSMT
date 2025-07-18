import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/presentation/sign_in/logics/sign_in_events.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(SignInInitial()) {
    on<SignInEmailEvent>(_onSignInEmail);
    on<SignOutEvent>(_onSignOut);
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();

  Future<void> _onSignInEmail(
      SignInEmailEvent event, Emitter<SignInState> emit) async {
    emit(SignInLoading());
    try {
      final user = await domainManager.auth.signInWithEmail(event.email, event.password);
      if (user != null) {
        emit(SignInSuccess(user.uid));
      } else {
        emit(SignInFailure('Sign in failed'));
      }
    } catch (e) {
      emit(SignInFailure(e.toString()));
    }
  }

  Future<void> _onSignOut(
      SignOutEvent event, Emitter<SignInState> emit) async {
    try {
      await domainManager.auth.signOut();
      emit(SignInInitial());
    } catch (e) {
      emit(SignInFailure('Sign out failed: ${e.toString()}'));
    }
  }
}
