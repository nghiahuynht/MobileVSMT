import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/logics/app_bloc.dart';
import '../../app/logics/app_state.dart';

/// Widget overlay để hiển thị loading toàn app
class AppLoadingOverlay extends StatelessWidget {
  final Widget child;

  const AppLoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state.isGlobalLoading) ...[
              // Overlay với màu nền mờ
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: _LoadingWidget(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Widget loading tùy chỉnh
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
              if (state.globalLoadingMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.globalLoadingMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
} 