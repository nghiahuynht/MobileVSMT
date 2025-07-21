import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/repository/auth/auth_repository.dart';
import 'package:trash_pay/l10n/app_localizations.dart';
import 'package:trash_pay/presentation/app/logics/app_bloc.dart';
import 'package:trash_pay/presentation/flash/logics/auth_bloc.dart';
import 'package:trash_pay/presentation/widgets/app/app_loading_overlay.dart';
import 'package:trash_pay/presentation/widgets/app/app_message_listener.dart';
import 'package:trash_pay/router/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: GetIt.I<AuthRepository>())),
      ],
      // child: AppMessageListener(
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        // builder: (context, child) {
        //   return AppLoadingOverlay(child: child ?? const SizedBox());
        // },
        ),
      // ),
    );
  }
}
