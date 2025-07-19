import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class _keys {
  static const String theme = 'app-theme';
  static const String token = 'token';
  static const String user = 'user';
  static const String companyCode = 'companyCode';
  static const String loginName = 'loginName';
  static const String password = 'password';
}

class UserPrefs {
  factory UserPrefs() => instance;
  UserPrefs._internal();

  static final UserPrefs instance = UserPrefs._internal();
  static UserPrefs get I => instance;
  late SharedPreferences _prefs;
  Future initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // theme
  ThemeMode getTheme() {
    final value = _prefs.getString(_keys.theme);
    return ThemeMode.values.firstWhere(
      (e) => e.toString().toLowerCase() == '$value'.toLowerCase(),
      orElse: () => ThemeMode.system,
    );
  }

  void setTheme(ThemeMode value) {
    _prefs.setString(_keys.theme, value.toString().toLowerCase());
  }

  String? getToken() {
    return _prefs.getString(_keys.token);
  }

  void setToken(String? value) {
    if (value == null) {
      _prefs.remove(_keys.token);
    } else {
      _prefs.setString(_keys.token, value);
    }
  }

  void setUser(String? value) {
    if (value == null) {
      _prefs.remove(_keys.user);
    } else {
      _prefs.setString(_keys.user, value);
    }
  }

  void setCompany(String? value) {
    if (value == null) {
      _prefs.remove(_keys.companyCode);
    } else {
      _prefs.setString(_keys.companyCode, value);
    }
  }

  String? getUser() {
    return _prefs.getString(_keys.user);
  }

  String? getCompany() {
    return _prefs.getString(_keys.companyCode);
  }

  String? getLoginName() {
    return _prefs.getString(_keys.loginName);
  }

  String? getPassword() {
    return _prefs.getString(_keys.password);
  }
  
  void setLoginName(String? value) {
    if (value == null) {
      _prefs.remove(_keys.loginName);
    } else {
      _prefs.setString(_keys.loginName, value);
    }
  }
  
  void setPassword(String? value) {
    if (value == null) {
      _prefs.remove(_keys.password);
    } else {
      _prefs.setString(_keys.password, value);
    }
  }
}
