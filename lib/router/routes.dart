import 'package:trash_pay/presentation/home/home_screen.dart';
import 'package:trash_pay/presentation/flash/flash_screen.dart';
import 'package:trash_pay/presentation/sign_in/sign_in_screen.dart';
import 'package:trash_pay/presentation/order/order_screen.dart';
import 'package:trash_pay/presentation/checkout/checkout_screen.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/checkout/checkout_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/presentation/order/logics/order_bloc.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/home',
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
    GoRoute(
      path: '/order',
      builder: (context, state) {
        final customer = state.extra as CustomerModel?;
        return BlocProvider(
          create: (context) => OrderBloc(),
          child: OrderScreen(customer: customer),
        );
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final checkoutData = state.extra as CheckoutData;
        return BlocProvider(
          create: (context) => OrderBloc(),
          child: CheckoutScreen(checkoutData: checkoutData),
        );
      },
    ),
  ],
);
