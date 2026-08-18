import 'package:flutter/material.dart';
import 'package:webview_master_app/config/app_config.dart';

/// Beautifully styled exit confirmation dialog
/// All colors configurable in AppConfig
class ExitDialog {
  /// Show exit confirmation dialog with animation
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ExitDialogWidget(),
    );
    return result ?? false;
  }
}

/// Animated exit dialog widget
class _ExitDialogWidget extends StatefulWidget {
  @override
  State<_ExitDialogWidget> createState() => _ExitDialogWidgetState();
}

class _ExitDialogWidgetState extends State<_ExitDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _exitWithAnimation(bool result) async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          // Background color from config with shadow
          backgroundColor: isDark
              ? AppConfig.exitDialogBackgroundDark
              : AppConfig.exitDialogBackgroundLight,

          // Shape with configurable border radius and elevation
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConfig.exitDialogBorderRadius),
          ),
          elevation: 8,

          // Content padding
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),

          // Icon + Title + Content
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConfig.exitDialogButtonColor.withOpacity(0.2),
                      AppConfig.exitDialogButtonColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 40,
                  color: AppConfig.exitDialogButtonColor,
                ),
              ),

              const SizedBox(height: 20),

              // Title with configurable colors
              Text(
                'Exit App?',
                style: TextStyle(
                  color: isDark
                      ? AppConfig.exitDialogTitleColorDark
                      : AppConfig.exitDialogTitleColorLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Description with better styling
              Text(
                'Are you sure you want to exit?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppConfig.exitDialogTextColorDark
                      : AppConfig.exitDialogTextColorLight,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),

          // Action buttons with better design
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            // Buttons in a row with equal width
            Row(
              children: [
                // Cancel button - Outlined style
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _exitWithAnimation(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark
                            ? AppConfig.exitDialogCancelColorDark
                                .withOpacity(0.3)
                            : AppConfig.exitDialogCancelColorLight
                                .withOpacity(0.3),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark
                            ? AppConfig.exitDialogCancelColorDark
                            : AppConfig.exitDialogCancelColorLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Exit button - Filled style with gradient
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConfig.exitDialogButtonColor,
                          AppConfig.exitDialogButtonColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppConfig.exitDialogButtonColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _exitWithAnimation(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
