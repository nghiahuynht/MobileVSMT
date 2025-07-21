import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/logics/app_bloc.dart';
import '../../app/logics/app_events.dart';
import '../../app/logics/app_state.dart';

/// Widget listener để hiển thị app messages
class AppMessageListener extends StatelessWidget {
  final Widget child;

  const AppMessageListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) => 
          previous.currentMessage != current.currentMessage,
      listener: (context, state) {
        if (state.hasMessage && state.currentMessage != null) {
          _showAppMessage(context, state.currentMessage!);
        }
      },
      child: child,
    );
  }

  void _showAppMessage(BuildContext context, AppMessage message) {
    final messenger = ScaffoldMessenger.of(context);
    
    // Clear existing snackbars
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIconForMessageType(message.type),
            color: _getColorForMessageType(message.type),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColorForMessageType(message.type),
      duration: message.duration ?? const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      action: SnackBarAction(
        label: 'Đóng',
        textColor: Colors.white,
        onPressed: () {
          messenger.hideCurrentSnackBar();
          context.read<AppBloc>().add(HideAppMessage());
        },
      ),
    );

    messenger.showSnackBar(snackBar);
  }

  IconData _getIconForMessageType(AppMessageType type) {
    switch (type) {
      case AppMessageType.success:
        return Icons.check_circle;
      case AppMessageType.error:
        return Icons.error;
      case AppMessageType.warning:
        return Icons.warning;
      case AppMessageType.info:
        return Icons.info;
    }
  }

  Color _getColorForMessageType(AppMessageType type) {
    switch (type) {
      case AppMessageType.success:
        return Colors.green.shade100;
      case AppMessageType.error:
        return Colors.red.shade100;
      case AppMessageType.warning:
        return Colors.orange.shade100;
      case AppMessageType.info:
        return Colors.blue.shade100;
    }
  }

  Color _getBackgroundColorForMessageType(AppMessageType type) {
    switch (type) {
      case AppMessageType.success:
        return Colors.green.shade600;
      case AppMessageType.error:
        return Colors.red.shade600;
      case AppMessageType.warning:
        return Colors.orange.shade600;
      case AppMessageType.info:
        return Colors.blue.shade600;
    }
  }
} 