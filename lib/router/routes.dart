import 'package:trash_pay/presentation/home/home_screen.dart';
import 'package:trash_pay/presentation/flash/flash_screen.dart';
import 'package:trash_pay/presentation/sign_in/sign_in_screen.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FlashPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
