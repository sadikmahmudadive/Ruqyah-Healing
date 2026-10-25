import 'dart:async';

import 'package:flutter/material.dart';

import '../services/prayer_times_service.dart';
import '../services/salah_schedule.dart';
import '../theme/app_theme.dart';
import 'animations/animations.dart';
import 'flowing_gradient.dart';
import 'islamic_pattern.dart';

/// Home's "next prayer" tile: the prayer's name, its Arabic name, when it
/// begins and how long until then, on a slowly drifting emerald gradient.
/// Tapping it opens the daily salah screen.
class NextPrayerTile extends StatefulWidget {
  final Future<PrayerTimesModel> future;
  final VoidCallback onTap;

  const NextPrayerTile({super.key, required this.future, required this.onTap});

  @override
  State<NextPrayerTile> createState() => _NextPrayerTileState();
}

class _NextPrayerTileState extends State<NextPrayerTile> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // The wait is shown in whole minutes, so a light refresh is plenty.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrayerTimesModel>(
      future: widget.future,
      builder: (context, snap) {
        final model = snap.data ?? PrayerTimesModel.fallback();
        final now = PrayerTimesService.nowAt(model.timezone);
        final schedule = SalahSchedule.from(model, date: now);
        final nowMin = now.hour * 60 + now.minute;
        // After Isha the next prayer is tomorrow's Fajr.
        final next = schedule.nextFard(nowMin) ?? schedule.fard.first;
        final wait = SalahSchedule.describeWait(
          schedule.minutesUntil(next, nowMin),
        );
        return _tile(context, next, wait);
      },
    );
  }

  Widget _tile(BuildContext context, SalahEntry next, String wait) {
    return Semantics(
      button: true,
      label:
          'Next prayer: ${next.name} at ${SalahSchedule.clock12(next.start)}, '
          'begins in $wait. Opens daily salah.',
      child: ExcludeSemantics(
        child: PressScale(
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: FlowingGradient(
              colors: const [
                Color(0xFF082F21),
                Color(0xFF0F593D),
                Color(0xFF14704B),
              ],
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                constraints: const BoxConstraints(minHeight: 128),
                foregroundDecoration: const IslamicPatternDecoration(
                  opacity: 0.08,
                  cell: 60,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'NEXT PRAYER',
                            style: AppType.eyebrow.copyWith(
                              color: AppColors.accentGoldSoft,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            next.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppType.display.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 15,
                                color: AppColors.accentGoldSoft,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'begins in $wait',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppType.caption.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 2,
                      // Scales down instead of overflowing at huge text sizes.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              next.arabic,
                              style: const TextStyle(
                                fontSize: 30,
                                height: 1.2,
                                color: AppColors.accentGoldSoft,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              SalahSchedule.clock12(next.start),
                              style: AppType.title.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.14),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: AppColors.accentGoldSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
