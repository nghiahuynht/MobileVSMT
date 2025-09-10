import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/sign_in/sign_in_response.dart';
import 'package:trash_pay/domain/entities/user/user.dart';
import 'package:trash_pay/domain/repository/auth/auth_repository.dart';
import 'package:trash_pay/services/network_service.dart';
import 'package:trash_pay/services/token_manager.dart';
import 'package:trash_pay/services/user_prefs.dart';
import 'package:trash_pay/services/app_messenger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioNetwork _networkService = DioNetwork.instance;
  final UserPrefs _userPrefs = UserPrefs.I;

  @override
  Future<SignInResponse?> signInWithLoginName(
      {required String loginName,
      required String password,
      required String companyCode, required String companyName}) async {
    try {
      final result = await _networkService.post<SignInResponse>(
        ApiConfig.loginEndpoint,
        data: {
          'companyCode': companyCode,
          'loginName': loginName,
          'password': password,
        },
        fromJson: (data) {
          // Some auth APIs return the token directly without isSuccess wrapper
          // If wrapped, enforce isSuccess; otherwise assume success
          if (data is Map<String, dynamic> && data.containsKey('isSuccess')) {
            if (data['isSuccess'] != true) {
              throw data['message'] ?? 'Đăng nhập thất bại';
            }
            return SignInResponse.fromMap(data['data'] as Map<String, dynamic>);
          }
          return SignInResponse.fromMap(data);
        },
      );

      if (result is Success<SignInResponse>) {
        final data = result.data;
        
        _userPrefs.setLoginName(loginName);
        _userPrefs.setPassword(password);
        _userPrefs.setCompany(companyCode);
        _userPrefs.setCompanyName(companyName);

        // IMPORTANT: Save token to TokenManager để authorization header được cập nhật ngay
        await TokenManager.instance.saveToken(data);

        return data;
      } else if (result is Failure<SignInResponse>) {
        AppMessenger.showError(result.errorResultEntity.message);
        throw Exception(result.errorResultEntity.message);
      }
      return null;
    } catch (e) {
      AppMessenger.showError(e.toString());
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = _userPrefs.getToken();
      if (token == null || token.isEmpty) return null;

      try {
        // _AuthInterceptor sẽ tự động add authorization header
        final result = await _networkService.get<UserModel>(
          ApiConfig.profileEndpoint,
          fromJson: (data) {
            return UserModel.fromJson(data);
          },
        );

        if (result is Success<UserModel>) {
          final userData = result.data;
          _userPrefs.setUser(userData.toJson());
          return userData;
        }
      } catch (e) {
        return null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    // Clear UserPrefs
    _userPrefs.setToken(null);
    _userPrefs.setUser(null);
    _userPrefs.setLoginName(null);
    _userPrefs.setPassword(null);
    _userPrefs.setCompany(null);
    
    // Clear TokenManager
    await TokenManager.instance.clearToken();
  }
}
