import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class AppToast {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 4),
  }) {
    HapticFeedback.selectionClick();

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        duration: duration,
        content: AppToastWidget(
          title: title,
          message: message,
          type: type,
          onDismiss: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

class AppToastWidget extends StatelessWidget {
  final String title;
  final String message;
  final ToastType type;
  final VoidCallback? onDismiss;

  const AppToastWidget({
    super.key,
    required this.title,
    required this.message,
    this.type = ToastType.success,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final ToastStyle style = _getStyle(type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Left Accent Border Strip
            Container(
              width: 5,
              height: 72,
              color: style.accentColor,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    // Icon Circle Container
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: style.iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          style.icon,
                          color: style.accentColor,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Title & Subtitle Column
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15221D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              color: Color(0xFF6E7E77),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Close/Dismiss Action Button
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (onDismiss != null) {
                          onDismiss!();
                        } else {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.cancel_outlined,
                          color: Color(0xFF90A4AE),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ToastStyle _getStyle(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const ToastStyle(
          accentColor: Color(0xFF0B4632),
          iconBgColor: Color(0xFFEBF7F0),
          icon: Icons.check_rounded,
        );
      case ToastType.error:
        return const ToastStyle(
          accentColor: Color(0xFFE74C3C),
          iconBgColor: Color(0xFFFFEBEB),
          icon: Icons.cancel_outlined,
        );
      case ToastType.warning:
        return const ToastStyle(
          accentColor: Color(0xFFD49E35),
          iconBgColor: Color(0xFFFFF8E1),
          icon: Icons.warning_amber_rounded,
        );
      case ToastType.info:
        return const ToastStyle(
          accentColor: Color(0xFF2980B9),
          iconBgColor: Color(0xFFE6F7FF),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class ToastStyle {
  final Color accentColor;
  final Color iconBgColor;
  final IconData icon;

  const ToastStyle({
    required this.accentColor,
    required this.iconBgColor,
    required this.icon,
  });
}
