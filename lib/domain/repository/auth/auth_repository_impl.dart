import 'package:dio/dio.dart';
import 'package:trash_pay/domain/entities/user/user.dart';
import 'package:trash_pay/domain/repository/auth/auth_repository.dart';
import 'package:trash_pay/services/user_prefs.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio = Dio();
  final UserPrefs _userPrefs = UserPrefs.I;
  
  // Replace with your actual API base URL
  static const String _baseUrl = 'https://your-api-url.com/api';
  
  // Demo mode for testing - set to false when you have a real API
  static const bool _demoMode = true;

  AuthRepositoryImpl() {
    if (!_demoMode) {
      _dio.options.baseUrl = _baseUrl;
      _dio.options.connectTimeout = const Duration(seconds: 5);
      _dio.options.receiveTimeout = const Duration(seconds: 3);
      
      // Add token interceptor
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = _userPrefs.getToken();
            if (token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );
    }
  }

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    if (_demoMode) {
      // Demo login - accept any email/password combination
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Simple validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }
      
      if (!email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }
      
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      // Create demo user
      final user = UserModel(
        uid: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: 'Demo User',
        photoUrl: null,
      );
      
      // Store demo token
      _userPrefs.setToken('demo_token_${user.uid}');
      
      return user;
    }
    
    // Real API implementation
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Store the token
        final token = data['token'] ?? data['access_token'];
        if (token != null) {
          _userPrefs.setToken(token);
        }

        // Create and return user model
        return UserModel(
          uid: data['user']['id']?.toString() ?? data['id']?.toString() ?? '',
          email: data['user']['email'] ?? data['email'],
          name: data['user']['name'] ?? data['name'],
          photoUrl: data['user']['avatar'] ?? data['avatar'],
        );
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  UserModel? getCurrentUser() {
    final token = _userPrefs.getToken();
    if (token.isEmpty) return null;
    
    if (_demoMode && token.startsWith('demo_token_')) {
      // Return a demo user for demo mode
      return UserModel(
        uid: token.replaceFirst('demo_token_', ''),
        email: 'demo@example.com',
        name: 'Demo User',
        photoUrl: null,
      );
    }
    
    // In a real app, you might want to decode the JWT token or make an API call
    // For now, we'll return null and let the app check authentication status differently
    return null;
  }

  @override
  Future<void> signOut() async {
    if (_demoMode) {
      // Just clear the token in demo mode
      _userPrefs.setToken(null);
      return;
    }
    
    try {
      final token = _userPrefs.getToken();
      if (token.isNotEmpty) {
        // Notify server about logout (optional)
        await _dio.post('/auth/logout');
      }
    } catch (e) {
      // Ignore errors during logout API call
    } finally {
      // Always clear local token
      _userPrefs.setToken(null);
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? e.response?.data['error'];
        
        switch (statusCode) {
          case 400:
            return message ?? 'Bad request';
          case 401:
            return message ?? 'Invalid credentials';
          case 403:
            return message ?? 'Access forbidden';
          case 404:
            return message ?? 'Service not found';
          case 422:
            return message ?? 'Validation error';
          case 500:
            return message ?? 'Server error';
          default:
            return message ?? 'Request failed';
        }
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.unknown:
        return 'Unknown error occurred';
      default:
        return 'Something went wrong';
    }
  }
}
