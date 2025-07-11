import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_boilerplate/presentation/home/logics/home_bloc.dart';
import 'package:flutter_boilerplate/presentation/home/logics/home_events.dart';
import 'package:flutter_boilerplate/presentation/home/logics/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => HomeBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trang Thanh Toán'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.replace('/login');
              },
            )
          ],
        ),
        body: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thanh toán thành công!')),
              );
            } else if (state is HomeFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Chọn phương thức thanh toán:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: state is HomeLoading
                        ? null
                        : () => context.read<HomeBloc>().add(
                            PayWithStripeCardEvent(
                                amount: 100, currency: 'USD')),
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Thanh toán bằng thẻ (Stripe)'),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 32),
                  if (state is HomeLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
