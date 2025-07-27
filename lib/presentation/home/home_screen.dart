import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trash_pay/presentation/home/logics/home_bloc.dart';
import 'package:trash_pay/presentation/customer/customer_list_screen.dart';
import 'package:trash_pay/presentation/order/order_list_screen.dart';
import 'package:trash_pay/presentation/order/logics/order_bloc.dart';
import 'package:trash_pay/presentation/reports/reports_screen.dart';
import 'package:trash_pay/presentation/reports/logics/report_bloc.dart';
import 'package:trash_pay/presentation/widgets/common/professional_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => HomeBloc(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8F9FA),
                Color(0xFFE9ECEF),
              ],
            ),
          ),
          child: Column(
            children: [
              // Professional Header
              ProfessionalHeaders.home(
                profileWidget: GestureDetector(
                  onTap: () {
                    context.push('/profile');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Main content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      
                      // Orders Card
                      _buildProfessionalFeatureCard(
                        context: context,
                        title: 'ĐƠN HÀNG',
                        subtitle: 'Quản lý đơn hàng thu gom',
                        icon: Icons.assignment_outlined,
                        iconColor: const Color(0xFF059669),
                        backgroundColor: const Color(0xFFF0FDF4),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => OrderBloc(),
                                child: const OrderListScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Customer List Card
                      _buildProfessionalFeatureCard(
                        context: context,
                        title: 'KHÁCH HÀNG',
                        subtitle: 'Danh sách và quản lý khách hàng',
                        icon: Icons.people_outline,
                        iconColor: const Color(0xFF0EA5E9),
                        backgroundColor: const Color(0xFFF0F9FF),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CustomerListScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Reports Card
                      _buildProfessionalFeatureCard(
                        context: context,
                        title: 'BÁO CÁO',
                        subtitle: 'Thống kê và phân tích doanh thu',
                        icon: Icons.analytics_outlined,
                        iconColor: const Color(0xFFDC2626),
                        backgroundColor: const Color(0xFFFEF2F2),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => ReportBloc(),
                                child: const ReportsScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // const SizedBox(height: 20),
                      
                      // // Settings Card
                      // _buildProfessionalFeatureCard(
                      //   context: context,
                      //   title: 'CÀI ĐẶT',
                      //   subtitle: 'Cấu hình hệ thống và tài khoản',
                      //   icon: Icons.settings_outlined,
                      //   iconColor: const Color(0xFF7C3AED),
                      //   backgroundColor: const Color(0xFFFAF5FF),
                      //   onTap: () {
                      //     // Navigate to settings
                      //   },
                      // ),
                      
                      const Spacer(),
                      
                      // Bottom info
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bản quyền thuộc về DVCI TEAM © 2025',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfessionalFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: iconColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconColor,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
