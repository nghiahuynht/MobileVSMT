import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/presentation/home/logics/home_events.dart';
import 'package:trash_pay/presentation/home/logics/home_state.dart';

class HomeBloc extends Bloc<HomeEvents, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<PayWithStripeCardEvent>(_handleStripeCard);
  }

  final DomainManager domainManager = GetIt.I<DomainManager>();

  Future<void> _handleStripeCard(
      PayWithStripeCardEvent event, Emitter<HomeState> emit) async {
    // emit(HomeLoading());
    // try {
    //   await domainManager.payment.processPayment(event.amount, event.currency);
    //   emit(HomeSuccess());
    // } catch (e) {
    //   emit(HomeFailure(e.toString()));
    // }
  }
}
