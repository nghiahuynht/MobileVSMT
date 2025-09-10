import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/constants/colors.dart';
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';
import 'package:trash_pay/presentation/report_detail/report_detail_screen.dart';
import 'package:trash_pay/presentation/reports/widgets/revenue_chart.dart';
import 'package:trash_pay/presentation/reports/widgets/revenue_list.dart';
import '../../constants/font_family.dart';
import '../widgets/common/professional_header.dart';
import 'logics/report_bloc.dart';
import 'logics/report_events.dart';
import 'logics/report_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadReportsEvent(
          year: DateTime.now().year,
          saleUserCode: context.userCode ?? '',
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocListener<ReportBloc, ReportState>(
        listener: (context, state) {
          // if (state is ReportError) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('Đã có lỗi xảy ra'),
          //       backgroundColor: Colors.red,
          //     ),
          //   );
          // }
        },
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            return Column(
              children: [
                // Header
                ProfessionalHeaders.detail(
                  title: 'Báo cáo',
                  subtitle: state is ReportsLoaded ? 'Năm ${state.year}' : null,
                  actionWidget: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final selectedYear = await showDialog<int>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Chọn năm'),
                              content: SizedBox(
                                width: 300,
                                height: 300,
                                child: YearPicker(
                                  firstDate: DateTime(now.year - 5),
                                  lastDate: DateTime(now.year),
                                  selectedDate: DateTime(now.year),
                                  onChanged: (date) {
                                    Navigator.of(context).pop(date.year);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        if (selectedYear != null) {
                          context
                              .read<ReportBloc>()
                              .add(LoadReportsEvent(
                                year: selectedYear,
                                saleUserCode: context.userCode ?? '',
                              ));
                        }
                      },
                      child: const Icon(
                        Icons.calendar_month,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            
                const SizedBox(height: 24),
            
                // Tab Content
                Expanded(
                  child: BlocBuilder<ReportBloc, ReportState>(
                    builder: (context, state) {
                      if (state is ReportLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        );
                      } else if (state is ReportsLoaded) {
                        return _buildOverviewTab(state);
                      } else if (state is ReportError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Có lỗi xảy ra',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                  fontFamily: FontFamily.productSans,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                  fontFamily: FontFamily.productSans,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => context.read<ReportBloc>().add(
                                      LoadReportsEvent(
                                        year: DateTime.now().year,
                                        saleUserCode: context.userCode ?? '',
                                      ),
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ReportsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevenueChart(data: state.data, year: state.year),
          const SizedBox(height: 24),
          RevenueSummaryTable(
            data: state.data,
            onRowTap: (value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReportDetailScreen(
                          month: int.parse(value.label?? ''),
                          year: state.year,
                        )),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
