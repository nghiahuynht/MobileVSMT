import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trash_pay/constants/colors.dart';
import '../../constants/font_family.dart';
import '../../domain/entities/unit/unit.dart';
import '../app/logics/app_bloc.dart';
import '../app/logics/app_events.dart';
import '../flash/logics/auth_bloc.dart';
import '../flash/logics/auth_events.dart';
import 'logics/sign_in_bloc.dart';
import 'logics/sign_in_events.dart';
import 'logics/sign_in_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _loginNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Unit> _units = [];
  Unit? _selectedUnit;
  bool _isLoadingUnits = false;

  late SignInBloc _signInBloc;

  @override
  void initState() {
    super.initState();

    // Khởi tạo SignInBloc và gọi LoadUnitsEvent ngay
    _signInBloc = SignInBloc();
    _loadUnits();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  void _loadUnits() {
    setState(() {
      _isLoadingUnits = true;
    });
    _signInBloc.add(LoadUnitsEvent());
  }

  @override
  void dispose() {
    _loginNameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _signInBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider.value(
        value: _signInBloc,
        child: BlocConsumer<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state is SignInFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã có lỗi xảy ra'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is SignInSuccess) {
              // Trigger AuthBloc để check lại auth status và lấy user info
              if (mounted) {
                context.read<AuthBloc>().add(CheckAuthStatus());
                // Load areas sau khi đăng nhập thành công
                context.read<AppBloc>().add(LoadAreasAfterLogin());
              }
              context.replace('/home');
            } else if (state is SignInSuccessWithUser) {
              // User info already retrieved, trigger AuthBloc and navigate
              if (mounted) {
                context.read<AuthBloc>().add(CheckAuthStatus());
                // Load areas sau khi đăng nhập thành công
                context.read<AppBloc>().add(LoadAreasAfterLogin());
              }
              context.replace('/home');
            } else if (state is UnitsLoaded) {
              setState(() {
                _units = state.units;
                _isLoadingUnits = false;
              });
            } else if (state is UnitsError) {
              setState(() {
                _isLoadingUnits = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              'Lỗi tải danh sách đơn vị: ${state.message}')),
                    ],
                  ),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return Container(
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
                  _buildHeader(),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        
                        // Login Form Section
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildLoginForm(context, state),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top < 30 ? 30 : MediaQuery.of(context).padding.top + 12,
        bottom: MediaQuery.of(context).padding.top < 30 ? 30 : MediaQuery.of(context).padding.top
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF334155),
            Color(0xFF475569),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          // Positioned.fill(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: const BorderRadius.only(
          //         bottomLeft: Radius.circular(32),
          //         bottomRight: Radius.circular(32),
          //       ),
          //       backgroundBlendMode: BlendMode.overlay,
          //       gradient: LinearGradient(
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //         colors: [
          //           Colors.white.withOpacity(0.1),
          //           Colors.transparent,
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // Content
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Icon
                // Container(
                //   width: 80,
                //   height: 80,
                //   decoration: BoxDecoration(
                //     color: AppColors.primary,
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: [
                //       BoxShadow(
                //         color: AppColors.primary.withOpacity(0.3),
                //         blurRadius: 20,
                //         offset: const Offset(0, 8),
                //       ),
                //     ],
                //   ),
                //   child: const Icon(
                //     Icons.recycling_rounded,
                //     size: 40,
                //     color: Colors.white,
                //   ),
                // ),

                // const SizedBox(height: 24),

                // App Title
                // Text(
                //   'TrashPay',
                //   style: TextStyle(
                //     fontSize: 32,
                //     fontWeight: FontWeight.w700,
                //     color: Colors.white,
                //     fontFamily: FontFamily.productSans,
                //     letterSpacing: -0.5,
                //   ),
                // ),
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  color: AppColors.primary,
                ),


                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Hệ thống quản lý dịch vụ công ích',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: FontFamily.productSans,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, SignInState state) {
    return Container(
      padding: const EdgeInsets.only(top: 32, left: 32, right: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Text
          Text(
            'Chào mừng trở lại!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              fontFamily: FontFamily.productSans,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Đăng nhập để tiếp tục sử dụng ứng dụng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              fontFamily: FontFamily.productSans,
            ),
          ),

          const SizedBox(height: 40),

          // Login Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Unit Dropdown
                _buildUnitDropdown(),

                const SizedBox(height: 20),

                // Login Name Field
                _buildLoginNameField(),

                const SizedBox(height: 20),

                // Password Field
                _buildPasswordField(),

                // const SizedBox(height: 16),

                // // Remember Me & Forgot Password
                // _buildRememberMeRow(),

                const SizedBox(height: 32),

                // Login Button
                _buildLoginButton(context, state),

                const SizedBox(height: 24),
              ],
            ),
          ),

          const Spacer(),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<Unit>(
      value: _selectedUnit,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: _isLoadingUnits ? 'Đang tải...' : 'Chọn đơn vị',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.business_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      items: _isLoadingUnits
          ? []
          : _units.map((Unit unit) {
              return DropdownMenuItem<Unit>(
                value: unit,
                child: Text(
                  unit.label ?? '',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontFamily.productSans,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
      onChanged: _isLoadingUnits
          ? null
          : (Unit? unit) {
              setState(() {
                _selectedUnit = unit;
              });
            },
      validator: (Unit? value) {
        if (value == null) {
          return 'Vui lòng chọn đơn vị';
        }
        return null;
      },
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontFamily: FontFamily.productSans,
      ),
      dropdownColor: Colors.white,
    );
  }

  Widget _buildLoginNameField() {
    return TextFormField(
      controller: _loginNameController,
      keyboardType: TextInputType.text,
      autocorrect: false,
      style: TextStyle(
        fontSize: 16,
        fontFamily: FontFamily.productSans,
      ),
      decoration: InputDecoration(
        labelText: 'Tên đăng nhập',
        hintText: 'Nhập tên đăng nhập',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.person_outline,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Vui lòng nhập tên đăng nhập';
        }
        if (val.length < 3) {
          return 'Tên đăng nhập phải có ít nhất 3 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(
        fontSize: 16,
        fontFamily: FontFamily.productSans,
      ),
      decoration: InputDecoration(
        labelText: 'Mật khẩu',
        hintText: 'Nhập mật khẩu của bạn',
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFF6B7280),
          ),
          onPressed: () => setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          }),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Vui lòng nhập mật khẩu';
        }
        if (val.length < 3) {
          return 'Mật khẩu phải có ít nhất 3 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        // Remember Me Checkbox
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) => setState(() {
                  _rememberMe = value ?? false;
                }),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Ghi nhớ đăng nhập',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                fontFamily: FontFamily.productSans,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Forgot Password
        GestureDetector(
          onTap: () {
            // Handle forgot password
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tính năng quên mật khẩu đang được phát triển'),
              ),
            );
          },
          child: Text(
            'Quên mật khẩu?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontFamily: FontFamily.productSans,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, SignInState state) {
    final isLoading = state is SignInLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF9CA3AF),
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.productSans,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
      child: Column(
        children: [
          // Copyright
          Text(
            'Bản quyền thuộc về DVCI TEAM © 2025',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
              fontFamily: FontFamily.productSans,
            ),
          ),
          Text(
            'Phiên bản 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
              fontFamily: FontFamily.productSans,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn đơn vị'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        return;
      }

      _signInBloc.add(
        SignInWithLoginNameEvent(
          _loginNameController.text.trim(),
          _passwordController.text,
          _selectedUnit!.code!,
          _selectedUnit!.label!,
        ),
      );
    }
  }
}
