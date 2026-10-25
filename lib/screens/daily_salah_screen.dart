import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import '../services/hijri_date.dart';
import '../services/prayer_location_service.dart';
import '../services/prayer_times_service.dart';
import '../services/salah_schedule.dart';
import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/animations/animations.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/modern_card.dart';
import '../widgets/prayer_location_sheet.dart';
import '../widgets/prayer_time_icon.dart';
import '../widgets/qibla_compass.dart';
import 'notification_settings_screen.dart';

const Color _goldSoft = Color(0xFFE9C26F);

/// Daily salah: what is next and how long until it, the five fard prayers for
/// the chosen day, and the voluntary prayers (Tahajjud, Ishraq, Chast) worked
/// out from the same API response. Opened by tapping Home's prayer times card.
class DailySalahScreen extends StatefulWidget {
  const DailySalahScreen({super.key});

  @override
  State<DailySalahScreen> createState() => _DailySalahScreenState();
}

class _DailySalahScreenState extends State<DailySalahScreen> {
  /// 0 = today at the chosen place, -1 = yesterday, 1 = tomorrow...
  int _dayOffset = 0;
  late Future<PrayerTimesModel> _future;
  Timer? _tick;
  String? _expanded;

  @override
  void initState() {
    super.initState();
    _future = _load();
    PrayerLocationService.instance.locationNotifier.addListener(_reload);
    // The wait is shown in minutes, so a light refresh is plenty.
    _tick = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    PrayerLocationService.instance.locationNotifier.removeListener(_reload);
    super.dispose();
  }

  Future<PrayerTimesModel> _load() {
    final date = _dayOffset == 0
        ? null
        : DateTime.now().add(Duration(days: _dayOffset));
    return PrayerTimesService.fetchPrayerTimes(date: date);
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _load());
  }

  void _moveDay(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _dayOffset = delta == 0 ? 0 : _dayOffset + delta;
      _expanded = null;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.darkHeaderOverlayStyle,
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: FutureBuilder<PrayerTimesModel>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return _loading(context);
            }
            return _content(context, snap.data ?? PrayerTimesModel.fallback());
          },
        ),
      ),
    );
  }

  // ─── Loading ────────────────────────────────────────────────

  Widget _loading(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            bottom: 24,
          ),
          foregroundDecoration: const IslamicPatternDecoration(
            radius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          decoration: BoxDecoration(
            gradient: AppGradients.headerGradient(context),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
          ),
          child: Row(
            children: [
              _headerButton(Icons.arrow_back_rounded, 'Back', () {
                Navigator.of(context).pop();
              }),
              const Expanded(
                child: Text(
                  'Daily Salah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Content ────────────────────────────────────────────────

  Widget _content(BuildContext context, PrayerTimesModel m) {
    final zoneNow = PrayerTimesService.nowAt(m.timezone);
    final date = DateTime(
      zoneNow.year,
      zoneNow.month,
      zoneNow.day + _dayOffset,
    );
    final isToday = _dayOffset == 0;
    final nowMin = zoneNow.hour * 60 + zoneNow.minute;
    final schedule = SalahSchedule.from(m, date: date);

    final next = isToday ? schedule.nextFard(nowMin) : null;
    // After Isha the next prayer is tomorrow's Fajr.
    final upcoming = isToday ? (next ?? schedule.fard.first) : null;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _header(context, schedule, isToday, upcoming, nowMin),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              FadeSlideIn(child: _dateNavigator(context, date, isToday)),
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: _fardCard(context, schedule, isToday, next, nowMin),
              ),
              const SizedBox(height: 32),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _sectionTitle(
                  context,
                  'Voluntary prayers',
                  "Worked out from this day's sunrise, sunset and night "
                      'timings.',
                ),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < schedule.nafl.length; i++) ...[
                FadeSlideIn(
                  delay: Duration(milliseconds: 160 + i * 50),
                  child: _naflCard(
                    context,
                    schedule.nafl[i],
                    isToday && _within(schedule.nafl[i], nowMin),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              const FadeSlideIn(
                delay: Duration(milliseconds: 360),
                child: QiblaCompassSection(),
              ),
              const SizedBox(height: 24),
              _footnote(context),
            ]),
          ),
        ),
      ],
    );
  }

  bool _within(SalahEntry e, int nowMin) =>
      e.end != null && nowMin >= e.start && nowMin < e.end!;

  // ─── Header with the arch ──────────────────────────────────

  Widget _header(
    BuildContext context,
    SalahSchedule schedule,
    bool isToday,
    SalahEntry? upcoming,
    int nowMin,
  ) {
    final fajr = schedule.fard.first.start;
    final isha = schedule.fard.last.start;
    // Guard the division: odd data (equal Fajr and Isha) must not give NaN.
    final span = isha - fajr;
    final progress = (!isToday || span <= 0)
        ? 0.0
        : ((nowMin - fajr) / span).clamp(0.0, 1.0);

    final title = isToday
        ? upcoming!.name
        : _dayOffset == 1
        ? 'Tomorrow'
        : _dayOffset == -1
        ? 'Yesterday'
        : 'Prayer times';
    final subtitle = isToday
        ? 'begins in ${SalahSchedule.describeWait(schedule.minutesUntil(upcoming!, nowMin))}'
        : 'for the day shown below';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 26,
      ),
      foregroundDecoration: const IslamicPatternDecoration(
        radius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _headerButton(Icons.arrow_back_rounded, 'Back', () {
                Navigator.of(context).pop();
              }),
              const Expanded(
                child: Text(
                  'Daily Salah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 14),
          _locationChip(context),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth.clamp(0.0, 340.0);
              return SizedBox(
                width: w,
                height: w / 2 + 16,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: AppMotion.extra,
                  curve: AppMotion.standard,
                  builder: (context, p, child) => CustomPaint(
                    painter: _ArchPainter(progress: p, showDot: isToday),
                    child: child,
                  ),
                  child: Align(
                    alignment: const Alignment(0, 0.45),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _goldSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth.clamp(0.0, 340.0);
              final style = TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.75),
              );
              return SizedBox(
                width: w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fajr ${SalahSchedule.clock12(fajr)}', style: style),
                    Text('Isha ${SalahSchedule.clock12(isha)}', style: style),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _headerButton(IconData icon, String label, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _locationChip(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        showPrayerLocationSheet(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: ListenableBuilder(
          listenable: PrayerLocationService.instance.locationNotifier,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded, size: 15, color: _goldSoft),
              const SizedBox(width: 6),
              Text(
                PrayerLocationService.instance.current.label,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Date navigator ────────────────────────────────────────

  Widget _dateNavigator(BuildContext context, DateTime date, bool isToday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final lang = AppLocalizations.currentLocale.languageCode;
    final hijri = HijriDate.fromGregorian(date);
    final gregorian =
        '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    final hijriText = '${hijri.day} ${hijri.monthName(lang)} ${hijri.year} AH';

    Widget arrow(IconData icon, String label, int delta) => Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () => _moveDay(delta),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: context.textPrimary, size: 22),
        ),
      ),
    );

    return ModernCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      radius: 22,
      child: Row(
        children: [
          arrow(Icons.chevron_left_rounded, 'Previous day', -1),
          Expanded(
            child: InkWell(
              onTap: isToday ? null : () => _moveDay(0),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isToday ? 'Today · $gregorian' : gregorian,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isToday ? hijriText : '$hijriText · tap for today',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: context.isDarkMode
                            ? AppColors.accentGoldSoft
                            : const Color(0xFF8A6420),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          arrow(Icons.chevron_right_rounded, 'Next day', 1),
        ],
      ),
    );
  }

  // ─── Fard prayers ──────────────────────────────────────────

  Widget _fardCard(
    BuildContext context,
    SalahSchedule schedule,
    bool isToday,
    SalahEntry? next,
    int nowMin,
  ) {
    return ModernCard(
      padding: const EdgeInsets.all(8),
      radius: 26,
      child: Column(
        children: [
          for (final e in schedule.fard)
            _fardRow(
              context,
              e,
              isNext: isToday && next != null && e.id == next.id,
              passed: isToday && e.start <= nowMin,
            ),
        ],
      ),
    );
  }

  Widget _fardRow(
    BuildContext context,
    SalahEntry e, {
    required bool isNext,
    required bool passed,
  }) {
    final onFill = isNext;
    final primary = onFill ? Colors.white : context.textPrimary;
    final secondary = onFill
        ? Colors.white.withValues(alpha: 0.78)
        : context.textSecondary;
    final iconName = e.id == 'dhuhr' && e.name != 'Dhuhr' ? 'Jummah' : e.name;

    return Semantics(
      container: true,
      label:
          '${e.name}, ${SalahSchedule.clock12(e.start)}'
          '${isNext
              ? ', next prayer'
              : passed
              ? ', time has begun'
              : ''}',
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: AppMotion.base,
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            gradient: onFill ? AppGradients.emeraldGradient : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: onFill
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onFill
                      ? Colors.white.withValues(alpha: 0.16)
                      : context.iconCircleBg,
                ),
                child: PrayerTimeIcon(
                  prayerName: iconName,
                  color: onFill
                      ? Colors.white
                      : (context.isDarkMode
                            ? AppColors.accentGold
                            : AppColors.primaryGreen),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.arabic,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    SalahSchedule.clock12(e.start),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    e.summary,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              _statusDot(context, isNext: isNext, passed: passed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusDot(
    BuildContext context, {
    required bool isNext,
    required bool passed,
  }) {
    if (isNext) {
      // The bell opens the reminder settings.
      return Semantics(
        button: true,
        label: 'Prayer reminders',
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(
              context,
            ).push(AppPageRoute.sharedAxis(const NotificationSettingsScreen()));
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: 18,
              color: _goldSoft,
            ),
          ),
        ),
      );
    }
    if (passed) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.containerBg,
        ),
        child: Icon(
          Icons.check_rounded,
          size: 18,
          color: context.isDarkMode
              ? AppColors.accentGold
              : AppColors.primaryGreen,
        ),
      );
    }
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.cardBorderStrong),
      ),
    );
  }

  // ─── Voluntary prayers ─────────────────────────────────────

  Widget _sectionTitle(BuildContext context, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            sub,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              height: 1.45,
              color: context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _naflIcon(String id) => switch (id) {
    'tahajjud' => Icons.nights_stay_outlined,
    'ishraq' => Icons.wb_twilight_rounded,
    _ => Icons.light_mode_outlined,
  };

  Widget _naflCard(BuildContext context, SalahEntry e, bool nowOpen) {
    final open = _expanded == e.id;
    final window = e.end == null
        ? SalahSchedule.clock12(e.start)
        : '${SalahSchedule.clock12(e.start)} – ${SalahSchedule.clock12(e.end!)}';
    final accent = context.isDarkMode
        ? AppColors.accentGold
        : AppColors.primaryGreen;

    return ModernCard(
      padding: EdgeInsets.zero,
      radius: 24,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _expanded = open ? null : e.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.isDarkMode
                        ? AppColors.darkIconCircleBg
                        : AppColors.tintSand,
                  ),
                  child: Icon(
                    _naflIcon(e.id),
                    size: 22,
                    color: context.isDarkMode
                        ? AppColors.accentGold
                        : const Color(0xFFB8862B),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              e.name,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            e.arabic,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textSecondary,
                            ),
                          ),
                          if (nowOpen) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.containerBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Open now',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        window,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: AppMotion.base,
                  curve: AppMotion.standard,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              alignment: Alignment.topCenter,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 1, color: context.cardBorder),
                          const SizedBox(height: 12),
                          _detailLine(context, 'Rakat', e.summary),
                          const SizedBox(height: 10),
                          _detailLine(context, 'How', e.howTo),
                          const SizedBox(height: 10),
                          _detailLine(context, 'Good to know', e.note),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailLine(BuildContext context, String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.textMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            height: 1.5,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _footnote(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Times come from the Aladhan API for '
        '${PrayerLocationService.instance.current.label}. The voluntary '
        'windows are guidance; scholars differ slightly on their edges. '
        'Qibla is the great-circle bearing to the Kaaba.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          height: 1.5,
          color: context.textMuted,
        ),
      ),
    );
  }
}

/// Semicircle from Fajr (left) to Isha (right) with a gold sun-dot for how far
/// through that span the day is.
class _ArchPainter extends CustomPainter {
  final double progress;
  final bool showDot;
  const _ArchPainter({required this.progress, required this.showDot});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final radius = size.width / 2 - stroke * 2;
    final center = Offset(size.width / 2, size.height - 12);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.14);
    canvas.drawArc(rect, math.pi, math.pi, false, track);

    if (!showDot) return;

    const pi = math.pi;
    final sweep = pi * progress;
    if (sweep > 0.001) {
      final done = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [Color(0xFFD49E35), Color(0xFFE9C26F)],
        ).createShader(rect);
      canvas.drawArc(rect, pi, sweep, false, done);
    }

    final angle = pi + sweep;
    final dot = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawCircle(
      dot,
      14,
      Paint()
        ..color = const Color(0xFFE9C26F).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(dot, 8, Paint()..color = const Color(0xFFE9C26F));
    canvas.drawCircle(
      dot,
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_ArchPainter old) =>
      old.progress != progress || old.showDot != showDot;
}
