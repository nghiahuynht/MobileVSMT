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
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      const data = [
        MonthlyRevenue(label: '1', revenue: 10000, totalCustomer: 100),
        MonthlyRevenue(label: '2', revenue: 2000, totalCustomer: 200),
        MonthlyRevenue(label: '3', revenue: 1500, totalCustomer: 150),
        MonthlyRevenue(label: '4', revenue: 1000, totalCustomer: 100),
        MonthlyRevenue(label: '5', revenue: 2000, totalCustomer: 200),
        MonthlyRevenue(label: '6', revenue: 3140, totalCustomer: 314),
        MonthlyRevenue(label: '7', revenue: 1000, totalCustomer: 100),
        MonthlyRevenue(label: '8', revenue: 2000, totalCustomer: 200),
        MonthlyRevenue(label: '9', revenue: 1000, totalCustomer: 100),
        MonthlyRevenue(label: '10', revenue: 1000, totalCustomer: 100),
        MonthlyRevenue(label: '11', revenue: 2000, totalCustomer: 200),
        MonthlyRevenue(label: '12', revenue: 3000, totalCustomer: 300),
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
