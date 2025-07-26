import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/presentation/report_detail/logics/report_detail_cubit.dart';
import 'package:trash_pay/presentation/reports/widgets/revenue_list.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';

class ReportDetailScreen extends StatelessWidget {
  final int month;
  final int year;
  const ReportDetailScreen({
    super.key,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => ReportDetailCubit(month, year),
        child: BlocBuilder<ReportDetailCubit, ReportDetailState>(
            builder: (context, state) {
          return Column(
            children: [
              ProfessionalHeaders.detail(
                title: 'Báo cáo',
                subtitle: state.isLoading ? null : 'Tháng ${month} Năm ${year}',
              ),
              Expanded(
                child: state.isLoading
                    ? _buildLoading()
                    : state.data.isNotEmpty
                        ? RevenueSummaryTable(
                            data: state.data,
                            isExpanded: true,
                          )
                        : _buildEmpty(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text('Không có dữ liệu'),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
      ),
    );
  }
}
