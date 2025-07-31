import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/repository/unit/unit_repository.dart';
import 'package:trash_pay/presentation/sign_in/logics/sign_in_events.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(SignInInitial()) {
    on<LoadUnitsEvent>(_onLoadUnits);
    on<SignInWithLoginNameEvent>(_onSignIn);
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();
  final UnitRepository unitRepository = GetIt.I<UnitRepository>();

  Future<void> _onLoadUnits(
      LoadUnitsEvent event, Emitter<SignInState> emit) async {
    emit(UnitsLoading());
    try {
      final units = await unitRepository.getUnits();
      emit(UnitsLoaded(units));
    } catch (e) {
      emit(UnitsError(e.toString()));
    }
  }

  Future<void> _onSignIn(
      SignInWithLoginNameEvent event, Emitter<SignInState> emit) async {
    emit(SignInLoading());
    try {
      final response = await domainManager.auth.signInWithLoginName(
        loginName: event.loginName,
        password: event.password,
        companyCode: event.companyCode,
        companyName: event.companyName,
      );
      if (response?.accessToken.isNotEmpty ?? false) {
        // Get user info after successful sign in
        try {
          final user = await domainManager.auth.getCurrentUser();
          if (user != null) {
            emit(SignInSuccessWithUser(user));
          } else {
            emit(SignInSuccess());
          }
        } catch (userError) {
          // If getting user info fails, still emit success but without user data
          emit(SignInSuccess());
        }
      } else {
        emit(SignInFailure('Sign in failed'));
      }
    } catch (e) {
      emit(SignInFailure(e.toString()));
    }
  }
}
