import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'order_list_filter_state.dart';

class OrderListFilterCubit extends Cubit<OrderListFilterState> {
  OrderListFilterCubit() : super(const OrderListFilterState());
}