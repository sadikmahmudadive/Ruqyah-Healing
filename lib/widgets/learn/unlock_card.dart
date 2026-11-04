import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../animations/press.dart';

/// Shown over a locked video when its free preview runs out.
///
/// It lives inside a 16:9 player (184 dp tall at 328 dp wide), so the layout
/// is compact: title, one line of copy, then Unlock and Replay side by side.
/// Text is capped at 1.3x inside the card, and as a last resort (very narrow
/// or very short parents) the whole card scales down instead of overflowing.
class UnlockCard extends StatelessWidget {
  const UnlockCard({
    super.key,
    required this.priceLabel,
    required this.onUnlock,
    this.onReplay,
  });

  /// Price text for the button, for example `BDT 1,200`. May be empty.
  final String priceLabel;
  final VoidCallback onUnlock;

  /// When set, a "Replay preview" button is shown beside Unlock.
  final VoidCallback? onReplay;

  static const String title = 'Preview ended';
  static const String subtitle = 'Enrol to keep watching.';
  static const String replayLabel = 'Replay preview';

  static const double _maxWidth = 320;
  static const double _maxTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    final label = priceLabel.trim().isEmpty
        ? 'Unlock course'
        : 'Unlock · ${priceLabel.trim()}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? math.min(_maxWidth, constraints.maxWidth)
            : _maxWidth;
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: width,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: _maxTextScale,
              child: _buildCard(context, label),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.accentGold,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppType.title.copyWith(
                    fontSize: 16,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppType.caption.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: PressScale(
                    onTap: onUnlock,
                    child: Semantics(
                      button: true,
                      label: label,
                      excludeSemantics: true,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppType.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (onReplay != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: PressScale(
                      onTap: onReplay,
                      child: Semantics(
                        button: true,
                        label: replayLabel,
                        excludeSemantics: true,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.cardBorderStrong),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            replayLabel,
                            textAlign: TextAlign.center,
                            style: AppType.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
