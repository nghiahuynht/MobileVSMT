import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/domain_manager.dart';
import 'report_events.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc() : super(ReportInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
  }

  final DomainManager _domainManager = DomainManager();

  Future<void> _onLoadReports(
      LoadReportsEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final revenueList =
          await _domainManager.report.getMonthlyRevenue(
        year: event.year,
        saleUserCode: event.saleUserCode,
      );

      emit(ReportsLoaded(
        year: event.year,
        data: revenueList,
      ));

    } catch (e) {
      emit(ReportError(message: 'Không thể tải báo cáo'));
    }
  }
}
