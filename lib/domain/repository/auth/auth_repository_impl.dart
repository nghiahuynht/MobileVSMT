import 'package:dio/dio.dart';
import 'package:trash_pay/constants/api_config.dart';
import 'package:trash_pay/domain/entities/based_api_result/api_result_model.dart';
import 'package:trash_pay/domain/entities/sign_in/sign_in_response.dart';
import 'package:trash_pay/domain/entities/user/user.dart';
import 'package:trash_pay/domain/repository/auth/auth_repository.dart';
import 'package:trash_pay/services/network_service.dart';
import 'package:trash_pay/services/token_manager.dart';
import 'package:trash_pay/services/user_prefs.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioNetwork _networkService = DioNetwork.instance;
  final UserPrefs _userPrefs = UserPrefs.I;

  @override
  Future<SignInResponse?> signInWithLoginName(
      {required String loginName,
      required String password,
      required String companyCode}) async {
    try {
      final result = await _networkService.post<SignInResponse>(
        ApiConfig.loginEndpoint,
        data: {
          'companyCode': companyCode,
          'loginName': loginName,
          'password': password,
        },
        fromJson: (data) {
          return SignInResponse.fromMap(data);
        },
      );

      if (result is Success<SignInResponse>) {
        final data = result.data;
        _userPrefs.setToken(data.toJson());

        _userPrefs.setLoginName(loginName);
        _userPrefs.setCompany(companyCode);

        return data;
      } else if (result is Failure<SignInResponse>) {
        throw Exception(result.errorResultEntity.message);
      }
      return null;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = _userPrefs.getToken();
      if (token == null || token.isEmpty) return null;

      try {
        final tokenMap = TokenManager.instance.currentToken;

        final result = await _networkService.get<UserModel>(
          ApiConfig.profileEndpoint,
          options: Options(
            headers: {
              'Authorization': tokenMap?.authorizationHeader,
              'accept': '*/*'
            },
          ),
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
    _userPrefs.setToken(null);
    _userPrefs.setUser(null);
    _userPrefs.setLoginName(null);
    _userPrefs.setCompany(null);
  }
}
