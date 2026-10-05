import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/notification_prefs.dart';
import '../services/notification_service.dart';
import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';

/// Which notifications the app sends, and whether the phone lets them through.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  final NotificationPrefs _prefs = NotificationPrefs.instance;

  bool? _osEnabled; // null while checking
  bool _exactAllowed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prefs.addListener(_onPrefsChanged);
    _refreshSystemState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _prefs.removeListener(_onPrefsChanged);
    super.dispose();
  }

  // The user may change the permission in system settings and come back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshSystemState();
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshSystemState() async {
    final enabled = await NotificationService.areEnabled();
    final exact = await NotificationService.canScheduleExact();
    if (!mounted) return;
    setState(() {
      _osEnabled = enabled;
      _exactAllowed = exact;
    });
  }

  Future<void> _turnOn() async {
    HapticFeedback.selectionClick();
    final granted = await NotificationService.requestPermission();
    await _refreshSystemState();
    if (!mounted) return;
    if (granted) {
      AppToast.show(
        context,
        title: 'Notifications on',
        message: 'You will now receive alerts from Ruqyah Healing.',
      );
    } else {
      AppToast.show(
        context,
        title: 'Still turned off',
        message:
            "Allow notifications for Ruqyah Healing in your phone's Settings.",
        type: ToastType.warning,
      );
    }
  }

  Future<void> _sendTest() async {
    HapticFeedback.selectionClick();
    if (!(_osEnabled ?? false)) {
      await _turnOn();
      if (!(_osEnabled ?? false)) return;
    }
    await NotificationService.showTest();
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    final blocked = _osEnabled == false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  if (blocked) _buildBlockedCard(),
                  if (!blocked && _isAndroid && !_exactAllowed)
                    _buildExactAlarmCard(),
                  if (blocked || (_isAndroid && !_exactAllowed))
                    const SizedBox(height: 16),

                  _sectionLabel('PRAYER TIMES'),
                  _card([
                    _switchRow(
                      title: 'Prayer time alerts',
                      subtitle: 'Fajr, Dhuhr, Asr, Maghrib and Isha',
                      value: _prefs.prayerEnabled,
                      onChanged: _prefs.setPrayerEnabled,
                    ),
                    if (_prefs.prayerEnabled) ...[
                      _divider(),
                      _leadTimeRow(),
                    ],
                  ]),

                  const SizedBox(height: 20),
                  _sectionLabel('SESSIONS & MESSAGES'),
                  _card([
                    _switchRow(
                      title: 'Appointment reminders',
                      subtitle: 'One hour before each booked session',
                      value: _prefs.appointmentsEnabled,
                      onChanged: _prefs.setAppointmentsEnabled,
                    ),
                    _divider(),
                    _switchRow(
                      title: 'Messages & updates',
                      subtitle:
                          'Therapist messages, order updates and announcements. '
                          'They always appear in your inbox.',
                      value: _prefs.messagesEnabled,
                      onChanged: _prefs.setMessagesEnabled,
                    ),
                  ]),

                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _sendTest,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Send a test notification'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── pieces ──────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.headerGradient(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
          const Text(
            'Notifications',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedCard() {
    return _banner(
      icon: Icons.notifications_off_outlined,
      color: AppColors.danger,
      title: 'Notifications are turned off',
      body:
          'Prayer times, reminders and messages cannot reach you until you '
          'allow notifications.',
      action: 'Turn on',
      onAction: _turnOn,
    );
  }

  Widget _buildExactAlarmCard() {
    return _banner(
      icon: Icons.schedule_rounded,
      color: AppColors.warning,
      title: 'Alerts may arrive a few minutes late',
      body:
          'Allow exact alarms so prayer reminders fire at the right minute.',
      action: 'Allow',
      onAction: () async {
        await NotificationService.requestExactAlarms();
        await _refreshSystemState();
      },
    );
  }

  Widget _banner({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    required String action,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    height: 1.35,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      action,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF90A4AE),
      ),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: context.cardBg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.cardBorder),
    ),
    child: Column(children: children),
  );

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(height: 1, color: context.cardBorder),
  );

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _leadTimeRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remind me',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in NotificationPrefs.leadOptions)
                ChoiceChip(
                  label: Text(m == 0 ? 'At prayer time' : '$m min before'),
                  selected: _prefs.prayerLeadMinutes == m,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _prefs.prayerLeadMinutes == m
                        ? Colors.white
                        : context.textPrimary,
                  ),
                  showCheckmark: false,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    _prefs.setPrayerLeadMinutes(m);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
