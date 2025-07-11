import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_boilerplate/presentation/sign_in/logics/sign_in_bloc.dart';
import 'package:flutter_boilerplate/presentation/sign_in/logics/sign_in_events.dart';
import 'package:flutter_boilerplate/presentation/sign_in/logics/sign_in_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (BuildContext context) => SignInBloc(),
        child: BlocConsumer<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state is SignInFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is SignInSuccess) {
              context.replace('/home');
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const FlutterLogo(size: 100),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (val) => val != null && val.contains('@')
                            ? null
                            : 'Email không hợp lệ',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        autocorrect: false,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            }),
                          ),
                        ),
                        validator: (val) => val != null && val.length >= 6
                            ? null
                            : 'Mật khẩu quá ngắn',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is SignInLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<SignInBloc>().add(
                                          SignInEmailEvent(
                                            _emailController.text,
                                            _passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          child: state is SignInLoading
                              ? const CircularProgressIndicator()
                              : const Text('Đăng nhập'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Đăng nhập bằng Google'),
                          onPressed: () => context
                              .read<SignInBloc>()
                              .add(SignInGoogleEvent()),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.apple),
                          label: const Text('Đăng nhập bằng Apple'),
                          onPressed: () => context
                              .read<SignInBloc>()
                              .add(SignInAppleEvent()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
