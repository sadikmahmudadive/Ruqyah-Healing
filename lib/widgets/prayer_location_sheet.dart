import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/prayer_location.dart';
import '../services/prayer_location_service.dart';
import '../theme/app_theme.dart';
import 'app_toast.dart';

/// Lets the user pick where prayer times are for: their phone's location
/// (kept up to date automatically) or any city.
Future<void> showPrayerLocationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PrayerLocationSheet(),
  );
}

class _PrayerLocationSheet extends StatefulWidget {
  const _PrayerLocationSheet();

  @override
  State<_PrayerLocationSheet> createState() => _PrayerLocationSheetState();
}

class _PrayerLocationSheetState extends State<_PrayerLocationSheet> {
  final PrayerLocationService _service = PrayerLocationService.instance;
  final TextEditingController _search = TextEditingController();

  Timer? _debounce;
  List<PrayerLocation> _results = const [];
  bool _searching = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQueryChanged(String text) {
    _debounce?.cancel();
    final q = text.trim();
    if (q.length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
        _lastQuery = '';
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final found = await _service.searchPlaces(q);
      if (!mounted || _search.text.trim() != q) return; // outdated
      setState(() {
        _results = found;
        _searching = false;
        _lastQuery = q;
      });
    });
  }

  Future<void> _pick(PrayerLocation place) async {
    HapticFeedback.selectionClick();
    await _service.selectManual(place);
    if (!mounted) return;
    Navigator.of(context).pop();
    AppToast.show(
      context,
      title: 'Prayer location updated',
      message: 'Showing prayer times for ${place.label}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: context.pageBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListenableBuilder(
          listenable: _service,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Prayer location',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: context.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    _buildAutoCard(),
                    const SizedBox(height: 18),
                    _buildSearchField(),
                    const SizedBox(height: 14),
                    if (_search.text.trim().length >= 2)
                      ..._buildResults()
                    else ...[
                      _label('POPULAR'),
                      for (final p in PrayerLocation.popular) _placeTile(p),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── auto-detect card ──────────────────────

  Widget _buildAutoCard() {
    final status = _service.status;
    final auto = _service.autoDetect;

    String subtitle;
    String? actionLabel;
    VoidCallback? action;

    if (!auto) {
      subtitle = 'Off. Choose a city below.';
    } else {
      switch (status) {
        case AutoLocationStatus.idle:
        case AutoLocationStatus.detecting:
          subtitle = 'Detecting your location…';
        case AutoLocationStatus.detected:
          subtitle = 'Using your location: ${_service.current.label}';
        case AutoLocationStatus.serviceOff:
          subtitle =
              'Location is turned off on your phone. Turn it on and prayer '
              'times will update automatically.';
          actionLabel = 'Turn on location';
          action = _service.openLocationSettings;
        case AutoLocationStatus.permissionDenied:
          subtitle = 'Allow location access to find your city.';
          actionLabel = 'Allow';
          action = () => _service.syncAuto(requestPermission: true);
        case AutoLocationStatus.permissionDeniedForever:
          subtitle = 'Location access is blocked for this app.';
          actionLabel = 'Open settings';
          action = _service.openAppSettings;
        case AutoLocationStatus.failed:
          subtitle = "Couldn't get your location.";
          actionLabel = 'Try again';
          action = () => _service.syncAuto(requestPermission: true);
      }
    }

    final detecting =
        auto &&
        (status == AutoLocationStatus.detecting ||
            status == AutoLocationStatus.idle);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: auto && status == AutoLocationStatus.detected
              ? AppColors.primaryGreen.withValues(alpha: 0.5)
              : context.cardBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: detecting
                ? const Padding(
                    padding: EdgeInsets.all(11),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.primaryGreen,
                    size: 21,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  'Use my current location',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    height: 1.35,
                    color: context.textSecondary,
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: action,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: auto,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              _service.setAutoDetect(v);
            },
          ),
        ],
      ),
    );
  }

  // ───────────────────────────── search ──────────────────────────────

  Widget _buildSearchField() {
    return TextField(
      controller: _search,
      onChanged: _onQueryChanged,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14.5,
        color: context.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Search any city',
        hintStyle: TextStyle(color: context.textSecondary),
        prefixIcon: Icon(Icons.search_rounded, color: context.textSecondary),
        suffixIcon: _search.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close_rounded, color: context.textSecondary),
                onPressed: () {
                  _search.clear();
                  _onQueryChanged('');
                },
              ),
        filled: true,
        fillColor: context.cardBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
      ),
    );
  }

  List<Widget> _buildResults() {
    if (_searching) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ),
        ),
      ];
    }
    if (_results.isEmpty && _lastQuery.isNotEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No places found for "$_lastQuery".',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: context.textSecondary,
              ),
            ),
          ),
        ),
      ];
    }
    return [for (final p in _results) _placeTile(p)];
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 8),
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

  Widget _placeTile(PrayerLocation place) {
    final selected =
        !_service.autoDetect && place.isSamePlaceAs(_service.current);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _pick(place),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primaryGreen : context.cardBorder,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: context.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    place.label,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
