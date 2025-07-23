import 'package:flutter/src/widgets/basic.dart';
import 'package:trash_pay/presentation/app/logics/app_bloc.dart';
import 'package:trash_pay/presentation/app/logics/app_state.dart';
import 'package:trash_pay/presentation/create_order/create_order_screen.dart';
import 'package:trash_pay/presentation/create_order/logics/create_order_bloc.dart';
import 'package:trash_pay/presentation/home/home_screen.dart';
import 'package:trash_pay/presentation/flash/flash_screen.dart';
import 'package:trash_pay/presentation/sign_in/sign_in_screen.dart';
import 'package:trash_pay/presentation/checkout/checkout_screen.dart';
import 'package:trash_pay/presentation/transaction/transaction_history_screen.dart';
import 'package:trash_pay/presentation/profile/profile_screen.dart';
import 'package:trash_pay/domain/entities/customer/customer.dart';
import 'package:trash_pay/domain/entities/checkout/checkout_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/presentation/order/logics/order_bloc.dart';
import 'package:trash_pay/presentation/transaction/logics/transaction_bloc.dart';
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
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/order',
      builder: (context, state) {
        final customer = state.extra as CustomerModel;
        return BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return BlocProvider(
              create: (context) => CreateOrderBloc(),
              child: ProductList(customer: customer, products: state.products),
            );
          }
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
    GoRoute(
      path: '/transaction-history',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        final customerId = params['customerId'] as String;
        final customerName = params['customerName'] as String;
        return BlocProvider(
          create: (context) => TransactionBloc(),
          child: TransactionHistoryScreen(
            customerId: customerId,
            customerName: customerName,
          ),
        );
      },
    ),
  ],
);
