import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/report/monthly_revenue.dart';

part 'report_detail_state.dart';

class ReportDetailCubit extends Cubit<ReportDetailState> {
  ReportDetailCubit(month, year, saleUserCode)
      : super(ReportDetailState(month: month, year: year, saleUserCode: saleUserCode)) {
    loadData();
  }

  final DomainManager _domainManager = DomainManager();

  void loadData() async {
    emit(state.copyWith(isLoading: true));

  try {
      final revenueList =
          await _domainManager.report.getMonthlyRevenueDetail(
        year: state.year,
        saleUserCode: state.saleUserCode,
        month: state.month,
      );

      emit(state.copyWith(data: revenueList, isLoading: false));

    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }

  }
}
