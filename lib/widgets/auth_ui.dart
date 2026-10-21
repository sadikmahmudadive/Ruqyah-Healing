import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'google_logo.dart';
import 'islamic_pattern.dart';

/// Shared building blocks for the sign-in and sign-up screens.
///
/// Look: a crisp night-sky painting across the top, the title sitting on it,
/// and a dark emerald sheet rising over it that carries the form. Gold is the
/// accent everywhere (active segment, focus ring, primary button).
class AuthColors {
  AuthColors._();

  static const Color sheet = Color(0xFF0A130F);
  static const Color field = Color(0xFF121E18);
  static const Color fieldBorder = Color(0xFF223A2F);
  static const Color emerald = Color(0xFF0F593D);
  static const Color gold = Color(0xFFD49E35);
  static const Color goldSoft = Color(0xFFE9C26F);
  static const Color onGold = Color(0xFF1A1405);
  static const Color textMuted = Color(0xFF92A89F);
}

/// Page frame. [children] go inside the sheet, in order, with a staggered
/// entrance; [onBack] adds a back button over the photo.
class AuthScaffold extends StatefulWidget {
  final String backgroundAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  /// Share of the screen height given to the photo + title area.
  final double heroFraction;
  final List<Widget> children;

  const AuthScaffold({
    super.key,
    required this.backgroundAsset,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
    this.heroFraction = 0.34,
  });

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _stagger(double begin, double end, Widget child) {
    final curve = CurvedAnimation(
      parent: _anim,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    final heroH = (size.height * widget.heroFraction).clamp(
      widget.onBack != null ? 270.0 : 250.0,
      400.0,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AuthColors.sheet,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AuthColors.sheet,
        body: Stack(
          children: [
            // Painting, fixed behind; the sheet slides over it.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroH + 90,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.backgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, _, _) => const SizedBox(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          AuthColors.sheet.withValues(alpha: 0.55),
                          AuthColors.sheet,
                        ],
                        stops: const [0.0, 0.3, 0.72, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 420,
              child: IslamicPattern(
                color: AuthColors.goldSoft,
                opacity: 0.09,
                cell: 76,
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: heroH,
                    child: Stack(
                      children: [
                        if (widget.onBack != null)
                          Positioned(
                            top: top + 8,
                            left: 20,
                            child: _BackButton(onTap: widget.onBack!),
                          ),
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: 30,
                          child: _stagger(0.0, 0.6, _buildTitleBlock()),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Sheet(
                    children: [
                      for (var i = 0; i < widget.children.length; i++)
                        _stagger(
                          (0.15 + i * 0.1).clamp(0.0, 0.7),
                          (0.7 + i * 0.1).clamp(0.0, 1.0),
                          widget.children[i],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AuthColors.goldSoft, AuthColors.gold],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: Colors.white,
            height: 1.2,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 14,
                color: Color(0xCC000000),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topLeft,
            children: [...previous, ?current],
          ),
          child: Text(
            widget.subtitle,
            key: ValueKey(widget.subtitle),
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.82),
              shadows: const [Shadow(blurRadius: 10, color: Color(0xCC000000))],
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: CircleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 17,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// The dark panel that rises over the painting.
class _Sheet extends StatelessWidget {
  final List<Widget> children;
  const _Sheet({required this.children});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 28, 24, 28 + bottom),
      decoration: BoxDecoration(
        color: AuthColors.sheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        border: Border(
          top: BorderSide(color: AuthColors.gold.withValues(alpha: 0.35)),
        ),
        boxShadow: [
          BoxShadow(
            color: AuthColors.gold.withValues(alpha: 0.10),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class AuthOption<T> {
  final T value;
  final String label;
  final IconData icon;
  const AuthOption(this.value, this.label, this.icon);
}

/// Segmented control whose gold thumb slides between options.
class AuthSegmented<T> extends StatelessWidget {
  final List<AuthOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const AuthSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final n = options.length;
    final index = options.indexWhere((o) => o.value == selected);
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AuthColors.field,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AuthColors.fieldBorder),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment(n == 1 ? 0 : -1 + 2 * index / (n - 1), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AuthColors.goldSoft, AuthColors.gold],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AuthColors.gold.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final o in options)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (o.value == selected) return;
                      HapticFeedback.selectionClick();
                      onChanged(o.value);
                    },
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: o.value == selected
                                ? AuthColors.onGold
                                : AuthColors.textMuted,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                o.icon,
                                size: 18,
                                color: o.value == selected
                                    ? AuthColors.onGold
                                    : AuthColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(o.label),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vertical, snapping carousel for picking one of several options (the
/// account role). The centred card is the selection and glows gold; the cards
/// above and below peek in, shrunk and faded, so it is obvious the list
/// scrolls and loops. Tapping a peeking card brings it to the centre.
class AuthCarousel<T> extends StatefulWidget {
  final List<AuthOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const AuthCarousel({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<AuthCarousel<T>> createState() => _AuthCarouselState<T>();
}

class _AuthCarouselState<T> extends State<AuthCarousel<T>> {
  static const double _itemHeight = 64;
  static const int _visible = 3;

  /// The carousel loops: pages are `options.length * _loops` long and each is
  /// mapped back with a modulo, so there is never an empty slot at the ends.
  static const int _loops = 1000;

  late final PageController _controller;

  int get _selectedIndex =>
      widget.options.indexWhere((o) => o.value == widget.selected);

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage:
          widget.options.length * (_loops ~/ 2) +
          _selectedIndex.clamp(0, widget.options.length - 1),
      viewportFraction: 1 / _visible,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _page() {
    if (_controller.hasClients && _controller.position.haveDimensions) {
      return _controller.page ?? _controller.initialPage.toDouble();
    }
    return _controller.initialPage.toDouble();
  }

  void _goTo(int index) {
    if (MediaQuery.of(context).disableAnimations) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemHeight * _visible,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemCount: widget.options.length * _loops,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              widget.onChanged(widget.options[i % widget.options.length].value);
            },
            itemBuilder: (context, i) => AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final distance = (_page() - i).abs().clamp(0.0, 1.0);
                return _card(i, distance);
              },
            ),
          ),
          // Fade the peeking cards into the sheet, like a wheel.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AuthColors.sheet.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.transparent,
                    AuthColors.sheet.withValues(alpha: 0.5),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(int index, double distance) {
    final o = widget.options[index % widget.options.length];
    final t = 1 - distance; // 1 = centred, 0 = fully off-centre
    final fg = Color.lerp(AuthColors.textMuted, AuthColors.onGold, t)!;
    return Semantics(
      button: true,
      selected: t > 0.5,
      label: o.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _goTo(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Transform.scale(
            scale: 0.9 + 0.1 * t,
            child: Opacity(
              opacity: 0.7 + 0.3 * t,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Color.lerp(AuthColors.field, AuthColors.gold, t),
                  gradient: t > 0.02
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(
                              AuthColors.field,
                              AuthColors.goldSoft,
                              t,
                            )!,
                            Color.lerp(AuthColors.field, AuthColors.gold, t)!,
                          ],
                        )
                      : null,
                  border: Border.all(
                    color: Color.lerp(
                      AuthColors.fieldBorder,
                      Colors.transparent,
                      t,
                    )!,
                  ),
                  boxShadow: t > 0.5
                      ? [
                          BoxShadow(
                            color: AuthColors.gold.withValues(alpha: 0.3 * t),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          Colors.white.withValues(alpha: 0.06),
                          AuthColors.onGold.withValues(alpha: 0.14),
                          t,
                        ),
                      ),
                      child: Icon(o.icon, size: 19, color: fg),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        o.label,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                    if (t > 0.5)
                      Icon(Icons.check_circle_rounded, size: 22, color: fg),
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

/// Label above a field.
class AuthLabel extends StatelessWidget {
  final String text;
  const AuthLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AuthColors.textMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Text input with a leading icon (or custom [prefix]), an optional trailing
/// widget, a built-in show/hide toggle for passwords and a gold focus ring.
class AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool enabled;
  final double letterSpacing;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.prefix,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.isPassword = false,
    this.enabled = true,
    this.letterSpacing = 0,
    this.onSubmitted,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;
  bool _hidden = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _focused ? AuthColors.goldSoft : AuthColors.textMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56,
      padding: EdgeInsets.only(left: widget.prefix != null ? 6 : 16, right: 14),
      decoration: BoxDecoration(
        color: AuthColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? AuthColors.gold : AuthColors.fieldBorder,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AuthColors.gold.withValues(alpha: 0.18),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (widget.prefix != null)
            widget.prefix!
          else if (widget.icon != null) ...[
            Icon(widget.icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              obscureText: widget.isPassword && _hidden,
              cursorColor: AuthColors.goldSoft,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.white,
                letterSpacing: widget.letterSpacing,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.5,
                  letterSpacing: 0,
                  color: Color(0xFF5E7268),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.isPassword)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _hidden = !_hidden),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: iconColor,
                ),
              ),
            )
          else if (widget.suffix != null)
            widget.suffix!,
        ],
      ),
    );
  }
}

/// Country selector used as a phone field prefix.
class AuthCountryPrefix extends StatelessWidget {
  final String flag;
  final String code;
  final VoidCallback onTap;
  const AuthCountryPrefix({
    super.key,
    required this.flag,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AuthColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 2),
        Container(width: 1, height: 22, color: AuthColors.fieldBorder),
        const SizedBox(width: 12),
      ],
    );
  }
}

/// Main call-to-action: a gold gradient with a soft glow. [tonal] gives the
/// quieter outlined variant used for secondary actions such as "Send OTP".
class AuthButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool tonal;
  final IconData? trailingIcon;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.tonal = false,
    this.trailingIcon,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final tonal = widget.tonal;
    final fg = tonal ? AuthColors.goldSoft : AuthColors.onGold;
    return AnimatedScale(
      scale: _down && enabled ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: widget.onPressed == null ? 0.5 : 1,
          child: Container(
            width: double.infinity,
            height: tonal ? 48 : 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tonal ? 14 : 18),
              gradient: tonal
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AuthColors.goldSoft, AuthColors.gold],
                    ),
              border: tonal
                  ? Border.all(color: AuthColors.gold.withValues(alpha: 0.6))
                  : null,
              boxShadow: tonal
                  ? null
                  : [
                      BoxShadow(
                        color: AuthColors.gold.withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: widget.loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: fg,
                      strokeWidth: 2.4,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: tonal ? 14.5 : 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: fg,
                        ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(widget.trailingIcon, size: 18, color: fg),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// "or continue with" divider.
class AuthDivider extends StatelessWidget {
  final String text;
  const AuthDivider(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: 1, color: AuthColors.fieldBorder),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              color: AuthColors.textMuted,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

/// Outlined "Continue with Google" button.
class AuthGoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const AuthGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuthColors.field,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white.withValues(alpha: 0.08),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AuthColors.fieldBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GoogleLogo(size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
