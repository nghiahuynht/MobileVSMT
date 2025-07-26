import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/domain/entities/report/monthly_revenue.dart';
import 'report_events.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc() : super(ReportInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
  }

  // Handle loading initial reports
  Future<void> _onLoadReports(
      LoadReportsEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    await Future.delayed(const Duration(seconds: 3));
    try {
      const data = [
        MonthlyRevenue(label: '1', revenue: 10000),
        MonthlyRevenue(label: '2', revenue: 2000),
        MonthlyRevenue(label: '3', revenue: 1500),
        MonthlyRevenue(label: '4', revenue: 1000),
        MonthlyRevenue(label: '5', revenue: 2000),
        MonthlyRevenue(label: '6', revenue: 3140),
        MonthlyRevenue(label: '7', revenue: 1000),
        MonthlyRevenue(label: '8', revenue: 2000),
        MonthlyRevenue(label: '9', revenue: 1000),
        MonthlyRevenue(label: '10', revenue: 1000),
        MonthlyRevenue(label: '11', revenue: 2000),
        MonthlyRevenue(label: '12', revenue: 3000),
      ];

      emit(ReportsLoaded(
        year: event.year,
        data: data,
      ));
    } catch (e) {
      emit(ReportError(message: 'Không thể tải báo cáo: ${e.toString()}'));
    }
  }
}
