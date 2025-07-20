import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:trash_pay/domain/domain_manager.dart';
import 'package:trash_pay/domain/entities/sign_in/sign_in_response.dart';

import 'user_prefs.dart';

class TokenManager {
  static final TokenManager instance = TokenManager._internal();
  factory TokenManager() => instance;
  TokenManager._internal();

  final _userPrefs = UserPrefs.I;
  final DomainManager _domainManager = DomainManager();

  SignInResponse? _currentToken;
  bool _isRefreshing = false;
  final List<Completer<String?>> _waitingRequests = [];

  /// Khởi tạo TokenManager và load token từ storage
  Future<void> initialize() async {
    await _loadTokenFromStorage();
  }

  /// Load token từ UserPrefs
  Future<void> _loadTokenFromStorage() async {
    try {
      final tokenJson = _userPrefs.getToken();
      if (tokenJson != null && tokenJson.isNotEmpty) {
        final tokenMap = jsonDecode(tokenJson);
        _currentToken = SignInResponse.fromMap(tokenMap);
        log('Token loaded from storage: ${_currentToken?.toString()}');
      }
    } catch (e) {
      log('Error loading token from storage: $e');
      _currentToken = null;
    }
  }

  /// Lưu token vào UserPrefs
  Future<void> saveToken(SignInResponse token) async {
    try {
      _currentToken = token;
      final tokenJson = jsonEncode(token.toJson());
      _userPrefs.setToken(tokenJson);
      log('Token saved to storage');
    } catch (e) {
      log('Error saving token: $e');
    }
  }

  /// Xóa token khỏi storage
  Future<void> clearToken() async {
    try {
      _currentToken = null;
      _userPrefs.setToken(null);
      log('Token cleared from storage');
    } catch (e) {
      log('Error clearing token: $e');
    }
  }

  /// Lấy token hiện tại, tự động refresh nếu cần
  Future<String?> getValidToken() async {
    // Nếu không có token
    if (_currentToken == null) {
      return null;
    }

    // Nếu token chưa hết hạn
    if (!_currentToken!.isExpired && !_currentToken!.isNearExpiry) {
      return _currentToken!.authorizationHeader;
    }

    // Nếu đang refresh, chờ kết quả
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _waitingRequests.add(completer);
      return await completer.future;
    }

    // Refresh token
    return await _refreshToken();
  }

  /// Refresh token
  Future<String?> _refreshToken() async {
    if (_isRefreshing) return null;

    _isRefreshing = true;
    log('Refreshing token...');

    try {
      // Gọi API refresh token (cần implement endpoint refresh token)

      final loginName = _userPrefs.getLoginName();
      final password = _userPrefs.getPassword();
      final companyCode = _userPrefs.getCompany();

      final response = await _domainManager.auth.signInWithLoginName(
          loginName: loginName!,
          password: password!,
          companyCode: companyCode!);

      if (response?.accessToken.isNotEmpty ?? false) {
        await saveToken(response!);

        // Hoàn thành tất cả requests đang chờ
        for (final completer in _waitingRequests) {
          completer.complete(response.authorizationHeader);
        }
        _waitingRequests.clear();

        log('Token refreshed successfully');
        return response.authorizationHeader;
      } else {
        throw Exception('Invalid refresh token response');
      }
    } catch (e) {
      log('Error refreshing token: $e');

      // Token refresh failed, clear token and redirect to login
      await clearToken();

      // Hoàn thành tất cả requests đang chờ với null
      for (final completer in _waitingRequests) {
        completer.complete(null);
      }
      _waitingRequests.clear();

      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Kiểm tra user đã đăng nhập hay chưa
  bool get isLoggedIn {
    return _currentToken != null && !_currentToken!.isExpired;
  }

  /// Lấy token hiện tại (không auto refresh)
  SignInResponse? get currentToken => _currentToken;

  /// Lấy access token thuần (không có Bearer prefix)
  String? get accessToken => _currentToken?.accessToken;

  /// Kiểm tra token có sắp hết hạn không
  bool get isTokenNearExpiry {
    return _currentToken?.isNearExpiry ?? true;
  }

  /// Lấy thời gian còn lại của token (phút)
  int get minutesUntilExpiry {
    return _currentToken?.minutesUntilExpiry ?? 0;
  }

  /// Force refresh token (dùng khi cần)
  Future<bool> forceRefresh() async {
    if (_currentToken == null) return false;

    final newToken = await _refreshToken();
    return newToken != null;
  }
}
