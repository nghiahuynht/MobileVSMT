// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'report_detail_cubit.dart';

class ReportDetailState extends Equatable {
  final int month;
  final int year;
  final List<MonthlyRevenue> data;
  final bool isLoading;
  final String saleUserCode;

  const ReportDetailState({
    required this.month,
    required this.year,
    this.data = const [],
    this.isLoading = false,
    required this.saleUserCode,
  });

  @override
  List<Object?> get props => [month, year, data, isLoading];

  ReportDetailState copyWith({
    int? month,
    int? year,
    List<MonthlyRevenue>? data,
    bool? isLoading,
    String? saleUserCode,
  }) {
    return ReportDetailState(
      month: month ?? this.month,
      year: year ?? this.year,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading, saleUserCode: saleUserCode ?? this.saleUserCode,
    );
  }
}
