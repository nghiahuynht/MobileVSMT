import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/font_family.dart';
import 'logics/sign_in_bloc.dart';
import 'logics/sign_in_events.dart';
import 'logics/sign_in_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (BuildContext context) => SignInBloc(),
        child: BlocConsumer<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state is SignInFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            } else if (state is SignInSuccess) {
              context.replace('/home');
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
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),
                    
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 280,
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
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                backgroundBlendMode: BlendMode.overlay,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.recycling_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App Title
                Text(
                  'TrashPay',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: FontFamily.productSans,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Waste Management System',
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
      padding: const EdgeInsets.all(32),
      child: Column(
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
                // Email Field
                _buildEmailField(),
                
                const SizedBox(height: 20),
                
                // Password Field
                _buildPasswordField(),
                
                const SizedBox(height: 16),
                
                // Remember Me & Forgot Password
                _buildRememberMeRow(),
                
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

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        style: TextStyle(
          fontSize: 16,
          fontFamily: FontFamily.productSans,
        ),
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'example@email.com',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.email_outlined,
              color: Color(0xFF059669),
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
            borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Vui lòng nhập email';
          }
          if (!val.contains('@') || !val.contains('.')) {
            return 'Email không hợp lệ';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
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
              color: const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Color(0xFF059669),
              size: 20,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
            borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Vui lòng nhập mật khẩu';
          }
          if (val.length < 6) {
            return 'Mật khẩu phải có ít nhất 6 ký tự';
          }
          return null;
        },
      ),
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
                activeColor: const Color(0xFF059669),
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
              color: const Color(0xFF059669),
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
          backgroundColor: const Color(0xFF059669),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF9CA3AF),
          elevation: 0,
          shadowColor: const Color(0xFF059669).withOpacity(0.3),
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
    return Column(
      children: [
        // Demo Credentials
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF059669).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF059669),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Demo Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                      fontFamily: FontFamily.productSans,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Email: demo@trashpay.com\nPassword: 123456',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                  fontFamily: FontFamily.productSans,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Copyright
        Text(
          '© 2024 TrashPay. All rights reserved.',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
            fontFamily: FontFamily.productSans,
          ),
        ),
      ],
    );
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<SignInBloc>().add(
        SignInEmailEvent(
          _emailController.text.trim(),
          _passwordController.text,
        ),
      );
    }
  }

  void _handleGoogleLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đăng nhập Google đang được phát triển'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  void _handleAppleLogin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đăng nhập Apple đang được phát triển'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }
}
