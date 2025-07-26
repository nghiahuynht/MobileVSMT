import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/report/monthly_revenue.dart';
import 'package:trash_pay/utils/utils.dart';

part 'report_detail_state.dart';

class ReportDetailCubit extends Cubit<ReportDetailState> {
  ReportDetailCubit(month, year)
      : super(ReportDetailState(month: month, year: year)) {
    loadData();
  }

  void loadData() {
    emit(state.copyWith(isLoading: true));

    final daysInMonth = Utils.getDaysInMonth(state.year, state.month);

    final data = <MonthlyRevenue>[];

    for (var i = 1; i <= daysInMonth; i++) {
      final label = i.toString();
      final revenue = 10000.toDouble();
      const totalCustomer = 100;
      final monthlyRevenue = MonthlyRevenue(
        label: label,
        revenue: revenue,
        totalCustomer: totalCustomer,
      );
      data.add(monthlyRevenue);
    }

    emit(state.copyWith(data: data, isLoading: false));
  }
}
