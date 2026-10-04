import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations/animations.dart';

/// A rounded surface with the app's standard border + layered shadow,
/// tappable with the shared [PressScale] feel.
///
/// Use this instead of a bare [Container] when you want cards to look
/// consistent across the app.
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final List<BoxShadow>? shadows;
  final Border? border;
  final bool enabled;
  final Gradient? gradient;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.onTap,
    this.onLongPress,
    this.color,
    this.shadows,
    this.border,
    this.enabled = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final bg = gradient == null ? (color ?? context.cardBg) : null;
    final b = border ??
        Border.all(
          color: context.cardBorder,
          width: 1,
        );

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: b,
        boxShadow: shadows ?? AppElevation.card,
      ),
      child: child,
    );

    if (onTap == null && onLongPress == null) return content;

    return PressScale(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: content,
    );
  }
}

/// A pill-shaped tappable chip.
class ModernChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final Color? selectedColor;

  const ModernChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final sel = selectedColor ?? const Color(0xFF0B4632);
    final bg = selected
        ? sel
        : (context.isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white);
    final fg = selected ? Colors.white : context.textPrimary;
    final borderColor =
        selected ? sel : context.cardBorder;

    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.standard,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: selected
              ? AppElevation.glow(sel, strength: 0.25)
              : AppElevation.subtle,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A glass panel — frosted translucent background behind content.
/// Use for floating overlays, modals, and sticky headers over imagery.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsets padding;
  final Color? tint;
  final Border? border;

  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 24,
    this.blur = 20,
    this.padding = const EdgeInsets.all(16),
    this.tint,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color = tint ??
        (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.55));
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: border ??
                Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.7),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
