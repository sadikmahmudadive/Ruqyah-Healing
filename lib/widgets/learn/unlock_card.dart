import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../animations/press.dart';

/// Shown over a locked video when its free preview runs out.
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

  /// When set, a "Replay preview" link is shown under the button.
  final VoidCallback? onReplay;

  static const String title = 'Preview ended';
  static const String subtitle = 'Enrol to keep watching the full lesson.';
  static const String replayLabel = 'Replay preview';

  @override
  Widget build(BuildContext context) {
    final label = priceLabel.trim().isEmpty
        ? 'Unlock course'
        : 'Unlock \u00B7 ${priceLabel.trim()}';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.containerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: AppColors.accentGold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppType.title.copyWith(
                fontSize: 16,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppType.caption.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: 14),
            PressScale(
              onTap: onUnlock,
              child: Semantics(
                button: true,
                label: label,
                excludeSemantics: true,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 44),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: AppType.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ),
              ),
            ),
            if (onReplay != null) ...[
              const SizedBox(height: 4),
              PressScale(
                onTap: onReplay,
                child: Semantics(
                  button: true,
                  label: replayLabel,
                  excludeSemantics: true,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    alignment: Alignment.center,
                    child: Text(
                      replayLabel,
                      style: AppType.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
