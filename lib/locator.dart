import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/repository/auth/auth_repository.dart';
import 'package:trash_pay/domain/repository/auth/auth_repository_impl.dart';
import 'package:trash_pay/domain/repository/unit/unit_repository.dart';
import 'package:trash_pay/domain/repository/unit/unit_repository_impl.dart';
import 'package:trash_pay/presentation/app/logics/app_bloc.dart';
import 'package:trash_pay/services/auth/firebase_auth_service.dart';
import 'package:trash_pay/services/token_manager.dart';
import 'package:trash_pay/services/user_prefs.dart';
import 'package:trash_pay/utils/bloc_observer.dart';
import 'package:trash_pay/utils/device/device_utils.dart';
import 'package:get_it/get_it.dart';

Future initializeApp({String? name}) async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  _locator();

  await Future.wait([
    DeviceUtils.loadInfo(),
    UserPrefs.instance.initialize(),
  ]);

  await TokenManager.instance.initialize();
  

  Bloc.observer = XBlocObserver();
}

void _locator() {
  GetIt.I.registerLazySingleton(() => FirebaseAuthService());
  GetIt.I.registerLazySingleton<UnitRepository>(() => UnitRepositoryImpl());
  GetIt.I.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  GetIt.I.registerLazySingleton(() => DomainManager());
  GetIt.I.registerLazySingleton(() => AppBloc());
}
