import 'package:flutter/material.dart';

class ProfessionalHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  const ProfessionalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingWidget,
    this.trailingWidget,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: gradientColors!,
              )
            : null,
        color: backgroundColor ?? 
               (gradientColors == null 
                   ? const Color(0xFF1E293B) 
                   : null),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Leading widget or back button
            if (showBackButton || leadingWidget != null) ...[
              showBackButton 
                  ? GestureDetector(
                      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : leadingWidget ?? const SizedBox.shrink(),
              const SizedBox(width: 16),
            ],
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFCBD5E1),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing widget
            if (trailingWidget != null) ...[
              const SizedBox(width: 16),
              trailingWidget!,
            ],
          ],
        ),
      ),
    );
  }
}

// Predefined header configurations for common use cases
class ProfessionalHeaders {
  // Home header configuration
  static ProfessionalHeader home({
    Widget? profileWidget,
  }) {
    return ProfessionalHeader(
      title: 'TrashPay',
      subtitle: 'Waste Management System',
      gradientColors: const [
        Color(0xFF1E293B),
        Color(0xFF334155),
        Color(0xFF475569),
      ],
      leadingWidget: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF059669),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.recycling_rounded,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
      trailingWidget: profileWidget ?? Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.account_circle_outlined,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }

  // Detail screen header with back button
  static ProfessionalHeader detail({
    required String title,
    String? subtitle,
    Widget? actionWidget,
    VoidCallback? onBackPressed,
  }) {
    return ProfessionalHeader(
      title: title,
      subtitle: subtitle,
      showBackButton: true,
      onBackPressed: onBackPressed,
      gradientColors: const [
        Color(0xFF1E293B),
        Color(0xFF334155),
        Color(0xFF475569),
      ],
      trailingWidget: actionWidget,
    );
  }

  // List screen header with add button
  static ProfessionalHeader list({
    required String title,
    String? subtitle,
    VoidCallback? onAddPressed,
    VoidCallback? onBackPressed,
    Widget? customActionWidget,
  }) {
    return ProfessionalHeader(
      title: title,
      subtitle: subtitle,
      showBackButton: true,
      onBackPressed: onBackPressed,
      gradientColors: const [
        Color(0xFF1E293B),
        Color(0xFF334155),
        Color(0xFF475569),
      ],
      trailingWidget: customActionWidget ?? (onAddPressed != null 
          ? GestureDetector(
              onTap: onAddPressed,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            )
          : null),
    );
  }
} 