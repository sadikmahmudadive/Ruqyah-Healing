import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/acupressure_icon.dart';
import '../widgets/acupuncture_icon.dart';
import '../widgets/hijama_cupping_icon.dart';
import '../widgets/ruqyah_dua_icon.dart';

/// One of the ten subject areas shared by the free Learn lessons and the
/// paid Courses. Exactly one of [icon] or [iconBuilder] is set. How many
/// lessons or courses a category holds is always counted from the data, never
/// stored here.
class LearnCategory {
  final String id;
  final String title;
  final IconData? icon;
  final Widget Function(double size)? iconBuilder;
  final Color tint;

  /// Colour for a plain [icon]; the custom [iconBuilder] icons carry their own.
  final Color iconColor;

  const LearnCategory({
    required this.id,
    required this.title,
    this.icon,
    this.iconBuilder,
    required this.tint,
    this.iconColor = _brandGreen,
  });

  /// The category icon at [size], whichever kind it is.
  Widget buildIcon(double size) {
    final builder = iconBuilder;
    if (builder != null) return builder(size);
    return Icon(icon ?? Icons.category_rounded, color: iconColor, size: size);
  }
}

const Color _brandGreen = Color(0xFF0B4632);

Widget _ruqyahIcon(double size) =>
    RuqyahDuaIcon(color: _brandGreen, size: size);
Widget _hijamaIcon(double size) =>
    HijamaCuppingIcon(color: AppColors.warning, size: size);
Widget _acupunctureIcon(double size) =>
    AcupunctureIcon(color: AppColors.info, size: size);
Widget _acupressureIcon(double size) =>
    AcupressureIcon(color: const Color(0xFF4E8F62), size: size);

const List<LearnCategory> kLearnCategories = [
  LearnCategory(
    id: 'quran',
    title: 'Quran Sikkha',
    icon: Icons.menu_book_rounded,
    tint: AppColors.tintMint,
  ),
  LearnCategory(
    id: 'hadis',
    title: 'Hadis Sikkha',
    icon: Icons.auto_stories_rounded,
    iconColor: AppColors.warning,
    tint: AppColors.tintSand,
  ),
  LearnCategory(
    id: 'sirat',
    title: 'Sirat Sikkha',
    icon: Icons.history_edu_rounded,
    iconColor: AppColors.info,
    tint: AppColors.tintMist,
  ),
  LearnCategory(
    id: 'ruqyah',
    title: 'Ruqyah',
    iconBuilder: _ruqyahIcon,
    tint: AppColors.tintMint,
  ),
  LearnCategory(
    id: 'hijama',
    title: 'Hijama',
    iconBuilder: _hijamaIcon,
    tint: AppColors.tintSand,
  ),
  LearnCategory(
    id: 'acupuncture',
    title: 'Acupuncture',
    iconBuilder: _acupunctureIcon,
    tint: AppColors.tintMist,
  ),
  LearnCategory(
    id: 'acupressure',
    title: 'Acupressure',
    iconBuilder: _acupressureIcon,
    tint: AppColors.tintSage,
  ),
  LearnCategory(
    id: 'homeopathy',
    title: 'Homeopathy',
    icon: Icons.medication_liquid_rounded,
    iconColor: AppColors.accentLilac,
    tint: AppColors.tintLilac,
  ),
  LearnCategory(
    id: 'naturopathy',
    title: 'Naturopathy',
    icon: Icons.spa_rounded,
    iconColor: AppColors.success,
    tint: AppColors.tintMint,
  ),
  LearnCategory(
    id: 'pathology',
    title: 'Pathology',
    icon: Icons.biotech_rounded,
    iconColor: AppColors.danger,
    tint: AppColors.tintRose,
  ),
];

/// The category with [id], or null when the id is unknown.
LearnCategory? learnCategoryById(String id) {
  for (final c in kLearnCategories) {
    if (c.id == id) return c;
  }
  return null;
}
