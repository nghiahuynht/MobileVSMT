import 'package:flutter/material.dart';

class AppMessenger {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showError(String? message) {
    final text = (message == null || message.isEmpty)
        ? 'Đã có lỗi xảy ra'
        : message;
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  static void showSuccess(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    }
  }
}


