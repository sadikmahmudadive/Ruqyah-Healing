import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/recitation_data.dart';
import '../../localization/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../models/recitation.dart';
import '../../services/firebase_service.dart';
import '../../services/health_index_service.dart';
import '../../services/notification_center.dart';
import '../../services/prayer_location_service.dart';
import '../../services/prayer_times_service.dart';
import '../../services/recitation_playback.dart';
import '../../services/recitation_player_controller.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_theme.dart';
import '../../widgets/acupuncture_icon.dart';
import '../../widgets/ai_icon.dart';
import '../../widgets/animations/animations.dart';
import '../../widgets/health_index_builder.dart';
import '../../widgets/hijama_cupping_icon.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/prayer_location_sheet.dart';
import '../../widgets/prayer_time_icon.dart';
import '../../widgets/ruqyah_dua_icon.dart';
import '../ai_symptom_guide_screen.dart';
import '../ayurvedic_hub_screen.dart';
import '../acupuncture_hub_screen.dart';
import '../book_appointment_screen.dart';
import '../emergency_ruqyah_screen.dart';
import '../full_audio_player_screen.dart';
import '../health_profile_detail_screen.dart';
import '../hijama_hub_screen.dart';
import '../notification_screen.dart';
import '../pathology_hub_screen.dart';
import '../ruqyah_hub_screen.dart';
import '../therapist_marketplace_screen.dart';

/// Modern Home tab.
///
/// Design changes vs. the previous version:
///   - Every section fades + slides in on first render (staggered).
///   - Health Index is computed from the user's profile and counts up from 0.
///   - Health Index gets an animated gradient fill bar below the number.
///   - The "Next Appointment" card uses the emerald gradient instead of
///     a flat primary color, with a sweeping shine overlay.
///   - Service icons pulse-scale on tap and have a soft glow.
///   - Active prayer slot gets a breathing pulse ring.
///   - Audio play button bounces between play/pause with a scale swap.
///   - Scrolls with a stretch overscroll effect (BouncingScrollPhysics
///     with alwaysScrollable).
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Held in state so rebuilds don't re-hit the network; replaced on refresh.
  late Future<PrayerTimesModel> _prayerTimesFuture;

  @override
  void initState() {
    super.initState();
    _prayerTimesFuture = PrayerTimesService.fetchPrayerTimes();
    PrayerLocationService.instance.locationNotifier.addListener(
      _onLocationChanged,
    );
    // Load the saved place, then follow the phone's location when it is on.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(PrayerLocationService.instance.start());
    });
  }

  @override
  void dispose() {
    PrayerLocationService.instance.locationNotifier.removeListener(
      _onLocationChanged,
    );
    super.dispose();
  }

  /// A different place was chosen or detected: load its prayer times.
  void _onLocationChanged() {
    if (!mounted) return;
    setState(() {
      _prayerTimesFuture = PrayerTimesService.fetchPrayerTimes();
    });
  }

  /// Pull-to-refresh: re-fetch prayer times. Health index and appointments
  /// are live Firestore streams, so they are already current.
  Future<void> _onRefresh() async {
    // Pick up a changed phone location first (no permission prompt here).
    await PrayerLocationService.instance.syncAuto();
    final future = PrayerTimesService.fetchPrayerTimes();
    setState(() => _prayerTimesFuture = future);
    // Keep the scheduled prayer alerts on the freshly fetched times.
    unawaited(NotificationCenter.resync());
    // Keep the spinner up long enough to read as a deliberate refresh.
    await Future.wait<void>([
      future.then<void>((_) {}).catchError((_) {}),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseService.currentUser;
    String userName = 'Guest User';
    if (currentUser != null) {
      if (currentUser.displayName?.isNotEmpty == true) {
        userName = currentUser.displayName!;
      } else if (currentUser.email?.isNotEmpty == true) {
        final emailPrefix = currentUser.email!.split('@').first;
        userName = emailPrefix.isNotEmpty
            ? emailPrefix[0].toUpperCase() + emailPrefix.substring(1)
            : 'User';
      } else if (currentUser.phoneNumber?.isNotEmpty == true) {
        userName = currentUser.phoneNumber!;
      } else {
        userName = 'User';
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.systemOverlayStyle,
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              AppRefreshSliver(onRefresh: _onRefresh),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Header
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 0),
                      child: _buildHeader(userName),
                    ),

                    const SizedBox(height: 20),

                    // 2. Bento row: Health + Next Appointment
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildHealthIndexCard()),
                            const SizedBox(width: 14),
                            Expanded(child: _buildNextAppointmentCard()),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 3. Audio player
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 160),
                      child: _buildAudioPlayerCard(),
                    ),

                    const SizedBox(height: 24),

                    // 4. Section header
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 220),
                      child: _buildSectionHeader(
                        context.tr('holistic_services'),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // 5. Services row
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 260),
                      beginOffset: const Offset(0.05, 0),
                      child: _buildServicesRow(),
                    ),

                    const SizedBox(height: 12),

                    // 6. Prayer times
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 320),
                      child: _buildPrayerTimesCard(),
                    ),

                    const SizedBox(height: 20),

                    // 7. Specialist card
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 380),
                      child: _buildSpecialistCard(),
                    ),

                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────── Header ─────────────────────────────
  Widget _buildHeader(String userName) {
    return Row(
      children: [
        // Avatar with soft ring
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.cardBorder, width: 2.0),
            boxShadow: AppElevation.subtle,
            image: const DecorationImage(
              image: AssetImage('assets/logo/logo_app.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamu Alaikum,',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        _CircleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => Navigator.of(context).push(
            AppPageRoute.sharedAxis(const NotificationScreen()),
          ),
        ),
        const SizedBox(width: 10),
        _CircleIconButton(
          customChild: AiIcon(color: context.textPrimary, size: 22),
          onTap: () => Navigator.of(context).push(
            AppPageRoute.sharedAxis(const AISymptomGuideScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
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
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─────────────────── Health Index Card ────────────────────────────
  Widget _buildHealthIndexCard() {
    return HealthIndexBuilder(
      builder: (context, health) => _buildHealthIndexCardBody(health),
    );
  }

  Widget _buildHealthIndexCardBody(HealthIndexResult health) {
    final score = health.score;
    final toneColor = health.tone.color;
    return ModernCard(
      onTap: () => Navigator.of(context).push(
        AppPageRoute.sharedAxis(const HealthProfileDetailScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr('health_index'),
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.wb_sunny_outlined,
                color: Color(0xFFD49E35),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              score == null
                  ? Text(
                      '--',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: context.textSecondary,
                        height: 1.0,
                      ),
                    )
                  : AnimatedCounter(
                      value: score,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                        height: 1.0,
                      ),
                    ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  score == null ? 'No data' : health.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: score == null ? context.textSecondary : toneColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Animated bar fill
          AnimatedBarFill(
            value: (score ?? 0) / 100,
            height: 5,
            color: toneColor,
          ),
          const SizedBox(height: 10),
          Text(
            score == null
                ? 'Complete a daily check-in to see your index'
                : 'Overall physical & spiritual wellness',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: context.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── Next Appointment Card ────────────────────────
  Widget _buildNextAppointmentCard() {
    final currentUser = FirebaseService.currentUser;

    if (currentUser == null) {
      return _buildAppointmentCardUI(
        dateText: 'No Active Booking',
        timeText: 'Sign in or explore sessions',
        doctorText: 'Browse Therapists',
        onTap: () => Navigator.of(context).push(
          AppPageRoute.sharedAxis(const TherapistMarketplaceScreen()),
        ),
      );
    }

    return StreamBuilder<List<AppointmentModel>>(
      stream: FirebaseService.getPatientAppointments(currentUser.uid),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        if (appointments.isEmpty) {
          return _buildAppointmentCardUI(
            dateText: 'No Active Booking',
            timeText: 'Schedule a new session',
            doctorText: 'Book a Therapist',
            onTap: () => Navigator.of(context).push(
              AppPageRoute.sharedAxis(const TherapistMarketplaceScreen()),
            ),
          );
        }

        final nextApp = appointments.first;
        final formattedDate =
            '${nextApp.scheduledTime.day}/${nextApp.scheduledTime.month}/${nextApp.scheduledTime.year}';
        final formattedTime =
            '${nextApp.scheduledTime.hour}:${nextApp.scheduledTime.minute.toString().padLeft(2, '0')}';
        return _buildAppointmentCardUI(
          dateText: formattedDate,
          timeText: formattedTime,
          doctorText: nextApp.therapyType.replaceAll('_', ' '),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildAppointmentCardUI({
    required String dateText,
    required String timeText,
    required String doctorText,
    required VoidCallback onTap,
  }) {
    return PressScale(
      onTap: onTap,
      hapticType: HapticFeedbackType.selection,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Gradient background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.emeraldGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('next_appointment'),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    doctorText,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD49E35),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── Audio Player Card ──────────────────────────
  Widget _buildAudioPlayerCard() {
    // Shares one controller with the full player, so playback started here
    // carries over when the card is opened (and back).
    return ListenableBuilder(
      listenable: RecitationPlayback.instance,
      builder: (context, _) {
        final controller = RecitationPlayback.instance.controller;
        if (controller == null) {
          return _buildAudioPlayerCardBody(
            kRecitationTracks[RecitationPlayback.defaultTrackId]!,
            null,
          );
        }
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) =>
              _buildAudioPlayerCardBody(controller.content, controller),
        );
      },
    );
  }

  void _onMiniPlayerPlayTap(RecitationPlayerController? controller) {
    if (controller == null) {
      // Nothing loaded yet: load the default recitation and start it.
      RecitationPlayback.instance.open(RecitationPlayback.defaultTrackId);
    } else {
      controller.togglePlayPause();
    }
  }

  String _clock(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Widget _buildAudioPlayerCardBody(
    RecitationContent content,
    RecitationPlayerController? controller,
  ) {
    final playing = controller?.playing ?? false;
    final loading = controller?.loading ?? false;
    final failed = controller?.error != null;

    // "Surah Al-Baqarah · Ayah 2:3" once loaded, plain title before that.
    final subtitle = controller == null
        ? content.title
        : '${content.title} · Ayah ${controller.currentAyah.ref}';

    return ModernCard(
      padding: const EdgeInsets.all(18),
      onTap: () => Navigator.of(context).push(
        AppPageRoute.sharedAxis(
          FullAudioPlayerScreen(
            title: content.title,
            verses: '${content.ayahs.length} ayahs',
            trackId: content.id,
            // Opening the card must not restart or change what is playing.
            autoplay: false,
            continueInBackground: true,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.arabicTitle,
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      failed
                          ? "Couldn't load audio. Tap play to retry."
                          : 'Recited by Sheikh Al-Afasy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: failed ? AppColors.danger : context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Play button with swap animation + ring glow when playing
              PressScale(
                hapticType: HapticFeedbackType.medium,
                onTap: () => _onMiniPlayerPlayTap(controller),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (playing)
                        const PulseRing(
                          color: AppColors.primaryGreen,
                          maxRadius: 28,
                          child: SizedBox(width: 48, height: 48),
                        ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: AppElevation.glow(
                            AppColors.primaryGreen,
                            strength: 0.3,
                          ),
                        ),
                        child: loading
                            ? const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : SwapReveal(
                                duration: AppMotion.fast,
                                child: Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  key: ValueKey<bool>(playing),
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress + times follow the playhead; tap the bar to jump to
          // that part of the recitation (by ayah).
          if (controller == null)
            _buildMiniProgress(content, null)
          else
            ValueListenableBuilder<Duration>(
              valueListenable: controller.position,
              builder: (context, _, _) => _buildMiniProgress(content, controller),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniProgress(
    RecitationContent content,
    RecitationPlayerController? controller,
  ) {
    final total = controller?.estimatedTotal ?? Duration.zero;
    final timeStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      color: context.textSecondary,
    );

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: controller == null
                ? null
                : (d) {
                    final n = content.ayahs.length;
                    final i = (d.localPosition.dx / constraints.maxWidth * n)
                        .floor()
                        .clamp(0, n - 1);
                    controller.playAyah(i);
                  },
            // Taller hit area than the 4px bar so it is easy to hit.
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AnimatedBarFill(
                value: controller?.overallProgress ?? 0,
                height: 4,
                color: AppColors.primaryGreen,
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Text(_clock(controller?.elapsed ?? Duration.zero), style: timeStyle),
            const Spacer(),
            Text(
              total == Duration.zero ? '--:--' : _clock(total),
              style: timeStyle,
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────── Services Row ───────────────────────────────
  Widget _buildServicesRow() {
    final isDark = context.isDarkMode;
    Color g(Color light) => isDark ? AppColors.accentGold : light;

    final services = <_ServiceSpec>[
      _ServiceSpec(
        label: context.tr('ruqyah'),
        customIcon: RuqyahDuaIcon(color: g(AppColors.primaryGreen), size: 30),
        bgColor: const Color(0xFFEBF7F0),
        iconColor: g(AppColors.primaryGreen),
        target: const RuqyahHubScreen(),
      ),
      _ServiceSpec(
        label: context.tr('hijama'),
        customIcon: HijamaCuppingIcon(color: g(AppColors.warning), size: 30),
        bgColor: const Color(0xFFFFF3E8),
        iconColor: g(AppColors.warning),
        target: const HijamaHubScreen(),
      ),
      _ServiceSpec(
        label: context.tr('acupuncture'),
        customIcon: AcupunctureIcon(color: g(AppColors.info), size: 30),
        bgColor: const Color(0xFFE6F7FF),
        iconColor: g(AppColors.info),
        target: const AcupunctureHubScreen(),
      ),
      _ServiceSpec(
        label: context.tr('ayurvedic'),
        icon: Icons.spa_outlined,
        bgColor: const Color(0xFFE8F8F5),
        iconColor: g(const Color(0xFF27AE60)),
        target: const AyurvedicHubScreen(),
      ),
      _ServiceSpec(
        label: context.tr('pathology'),
        icon: Icons.biotech_outlined,
        bgColor: const Color(0xFFF4ECF7),
        iconColor: g(const Color(0xFF8E44AD)),
        target: const PathologyHubScreen(),
      ),
      _ServiceSpec(
        label: context.tr('emergency'),
        icon: Icons.error_outline_rounded,
        bgColor: const Color(0xFFFFEBEB),
        iconColor: g(AppColors.danger),
        target: const EmergencyRuqyahScreen(),
      ),
    ];

    // Full-bleed row: cancels the page's 20px horizontal inset so the list
    // scrolls edge-to-edge. Padding lives inside the ListView so the circle
    // shadows have room before the viewport clips them.
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: 116,
        child: OverflowBox(
          minWidth: constraints.maxWidth + 40,
          maxWidth: constraints.maxWidth + 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            itemCount: services.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final s = services[i];
              return FadeSlideIn(
                delay: Duration(milliseconds: 60 * i),
                beginOffset: const Offset(0.15, 0),
                child: _buildServiceIconCard(s),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildServiceIconCard(_ServiceSpec s) {
    return PressScale(
      onTap: () =>
          Navigator.of(context).push(AppPageRoute.sharedAxis(s.target)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? AppColors.darkIconCircleBg
                  : s.bgColor,
              shape: BoxShape.circle,
              boxShadow: context.isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: s.iconColor.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: s.customIcon ??
                  Icon(s.icon, color: s.iconColor, size: 30),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────── Prayer Times Card ──────────────────────────
  Widget _buildPrayerTimesCard() {
    return ModernCard(
      // No horizontal padding here: the slot list spans the full card width so
      // the active slot's glow isn't clipped; the header re-applies the inset.
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  context.tr('prayer_times'),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                // Tap to choose where prayer times are for.
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        showPrayerLocationSheet(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: ListenableBuilder(
                          listenable: Listenable.merge([
                            PrayerLocationService.instance,
                            PrayerLocationService.instance.locationNotifier,
                          ]),
                          builder: (context, _) {
                            final svc = PrayerLocationService.instance;
                            final accent = context.isDarkMode
                                ? AppColors.accentGold
                                : AppColors.primaryGreen;
                            final following =
                                svc.autoDetect &&
                                svc.status == AutoLocationStatus.detected;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  following
                                      ? Icons.my_location_rounded
                                      : Icons.location_on_rounded,
                                  size: 14,
                                  color: accent,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    svc.current.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: accent,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<PrayerTimesModel>(
            future: _prayerTimesFuture,
            builder: (context, snapshot) {
              final times = snapshot.data ?? PrayerTimesModel.fallback();
              final activePrayer =
                  PrayerTimesService.getActivePrayerName(times);

              final prayers = <(String, String)>[
                ('Fajr', times.fajr),
                ('Dhuhr', times.dhuhr),
                ('Asr', times.asr),
                ('Maghrib', times.maghrib),
                ('Isha', times.isha),
                ('Jummah', times.jummah),
              ];

              return SizedBox(
                height: 122,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
                  itemCount: prayers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final (name, time) = prayers[i];
                    final isActive = activePrayer == name;
                    return _buildPrayerSlot(
                      name: name,
                      time: time,
                      isActive: isActive,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSlot({
    required String name,
    required String time,
    required bool isActive,
  }) {
    if (isActive) {
      final card = Container(
        constraints: const BoxConstraints(minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppGradients.greenButtonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrayerTimeIcon(prayerName: name, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.90),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD49E35),
              ),
            ),
          ],
        ),
      );
      return BreathingPulse(maxScale: 1.03, child: card);
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrayerTimeIcon(
            prayerName: name,
            color: context.isDarkMode
                ? AppColors.darkTextMuted
                : const Color(0xFF52625B),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────── Specialist Card ────────────────────────────
  Widget _buildSpecialistCard() {
    return ModernCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A2F),
                image: DecorationImage(
                  image: AssetImage('assets/logo/logo_app.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Salma Rahman',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Licensed Ruqyah Specialist',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD49E35),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.9 ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD49E35),
                      ),
                    ),
                    Text(
                      '(120 reviews)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _GradientButton(
            label: 'Book',
            onTap: () => Navigator.of(context).push(
              AppPageRoute.sharedAxis(
                const BookAppointmentScreen(
                  therapistName: 'Dr. Salma Rahman',
                  basePrice: 1200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Internal pieces ──────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customChild;
  final VoidCallback onTap;
  const _CircleIconButton({this.icon, this.customChild, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.cardBg,
          shape: BoxShape.circle,
          border: Border.all(color: context.cardBorder, width: 1.0),
          boxShadow: AppElevation.subtle,
        ),
        alignment: Alignment.center,
        child: customChild ??
            Icon(icon, color: context.textPrimary, size: 22),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      hapticType: HapticFeedbackType.medium,
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: AppGradients.greenButtonGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppElevation.glow(AppColors.primaryGreen, strength: 0.25),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ServiceSpec {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final Color bgColor;
  final Color iconColor;
  final Widget target;

  const _ServiceSpec({
    required this.label,
    this.icon,
    this.customIcon,
    required this.bgColor,
    required this.iconColor,
    required this.target,
  });
}
