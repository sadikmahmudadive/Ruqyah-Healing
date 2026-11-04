import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'empty_state.dart' show FloatingIllustration;
import 'google_logo.dart';
import 'illustrations/ruqyah_illustrations.dart';
import 'islamic_pattern.dart';

/// Shared building blocks for the sign-in and sign-up screens.
///
/// Look: calm and minimal. A quiet page (ivory in light mode, deep green in
/// dark), a small floating mosque illustration, a centred title, and flat
/// fields with hairline borders. One solid accent colour does the work:
/// emerald in light mode, gold in dark mode.
extension AuthPalette on BuildContext {
  Color get authBg => pageBg;
  Color get authField => cardBg;
  Color get authBorder => cardBorderStrong;
  Color get authText => textPrimary;
  Color get authMuted => textSecondary;

  /// The one solid accent: buttons, the selected segment, the focus ring.
  Color get authAccent =>
      isDarkMode ? AppColors.accentGold : AppColors.primaryGreen;

  /// Text drawn on top of [authAccent].
  Color get authOnAccent =>
      isDarkMode ? const Color(0xFF1A1405) : Colors.white;

  /// Inline links ("Forgot password?", "Sign up").
  Color get authLink =>
      isDarkMode ? const Color(0xFFE9C26F) : AppColors.primaryGreen;
}

/// Page frame. [children] go below the header, in order, with a staggered
/// entrance; [onBack] adds a back button above the illustration.
class AuthScaffold extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  /// A smaller illustration, for long forms.
  final bool compact;
  final List<Widget> children;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
    this.compact = false,
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
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_anim.isAnimating || _anim.isCompleted) return;
    // With reduced motion everything is simply there.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _anim.value = 1;
    } else {
      _anim.forward();
    }
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
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final illoW = widget.compact ? 124.0 : 156.0;
    final illoH = illoW * 0.75;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.systemOverlayStyle.copyWith(
        systemNavigationBarColor: context.authBg,
        systemNavigationBarIconBrightness: context.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.authBg,
        body: Stack(
          children: [
            // A faint geometric wash behind the header, fading out.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: IslamicPattern(
                color: context.authAccent,
                opacity: context.isDarkMode ? 0.07 : 0.05,
                cell: 72,
                fadeDown: true,
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, top + 12, 24, 0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 44,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: widget.onBack != null
                                ? _BackButton(onTap: widget.onBack!)
                                : null,
                          ),
                        ),
                        SizedBox(height: widget.compact ? 0 : 8),
                        _stagger(
                          0.0,
                          0.55,
                          ExcludeSemantics(
                            child: FloatingIllustration(
                              child: MosqueSceneIllustration(
                                width: illoW,
                                height: illoH,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: widget.compact ? 12 : 20),
                        _stagger(0.08, 0.65, _buildTitleBlock(context)),
                        SizedBox(height: widget.compact ? 20 : 28),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < widget.children.length; i++)
                          _stagger(
                            (0.2 + i * 0.1).clamp(0.0, 0.7),
                            (0.75 + i * 0.1).clamp(0.0, 1.0),
                            widget.children[i],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBlock(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: context.authText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.subtitle,
            key: ValueKey(widget.subtitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              height: 1.45,
              color: context.authMuted,
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
    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: context.authField,
        shape: CircleBorder(side: BorderSide(color: context.authBorder)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: context.authText,
            ),
          ),
        ),
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

/// Segmented control whose solid thumb slides between options.
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
        color: context.authField,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.authBorder),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: AlignmentDirectional(
              n == 1 ? 0 : -1 + 2 * index / (n - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.authAccent,
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final o in options)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: o.value == selected,
                    label: o.label,
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
                                  ? context.authOnAccent
                                  : context.authMuted,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  o.icon,
                                  size: 18,
                                  color: o.value == selected
                                      ? context.authOnAccent
                                      : context.authMuted,
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
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vertical, snapping carousel for picking one of several options (the
/// account role). The centred card is the selection and fills with the
/// accent; the cards above and below peek in, shrunk and faded, so it is
/// obvious the list scrolls and loops. Tapping a peeking card brings it to
/// the centre.
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
    final bg = context.authBg;
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
                return _card(context, i, distance);
              },
            ),
          ),
          // Fade the peeking cards into the page, like a wheel.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bg.withValues(alpha: 0.7),
                    Colors.transparent,
                    Colors.transparent,
                    bg.withValues(alpha: 0.7),
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

  Widget _card(BuildContext context, int index, double distance) {
    final o = widget.options[index % widget.options.length];
    final t = 1 - distance; // 1 = centred, 0 = fully off-centre
    final fg = Color.lerp(context.authMuted, context.authOnAccent, t)!;
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
            scale: 0.92 + 0.08 * t,
            child: Opacity(
              opacity: 0.7 + 0.3 * t,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color.lerp(context.authField, context.authAccent, t),
                  border: Border.all(
                    color: Color.lerp(
                      context.authBorder,
                      Colors.transparent,
                      t,
                    )!,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          context.authAccent.withValues(alpha: 0.08),
                          context.authOnAccent.withValues(alpha: 0.16),
                          t,
                        ),
                      ),
                      child: Icon(o.icon, size: 19, color: fg),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        o.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: context.authMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Text input with a leading icon (or custom [prefix]), an optional trailing
/// widget, a built-in show/hide toggle for passwords and an accent focus ring.
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
    final iconColor = _focused ? context.authAccent : context.authMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56,
      padding: EdgeInsets.only(left: widget.prefix != null ? 6 : 16, right: 14),
      decoration: BoxDecoration(
        color: context.authField,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? context.authAccent : context.authBorder,
          width: _focused ? 1.5 : 1,
        ),
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
              cursorColor: context.authAccent,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: context.authText,
                letterSpacing: widget.letterSpacing,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.5,
                  letterSpacing: 0,
                  color: context.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.isPassword)
            Semantics(
              button: true,
              label: _hidden ? 'Show password' : 'Hide password',
              child: GestureDetector(
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
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.authText,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: context.authMuted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 2),
        Container(width: 1, height: 22, color: context.authBorder),
        const SizedBox(width: 12),
      ],
    );
  }
}

/// Main call-to-action: a solid accent fill, no glow. [tonal] gives the
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
    final fg = tonal ? context.authLink : context.authOnAccent;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: AnimatedScale(
        scale: _down && enabled ? 0.98 : 1,
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
                borderRadius: BorderRadius.circular(tonal ? 14 : 16),
                color: tonal ? null : context.authAccent,
                border: tonal
                    ? Border.all(
                        color: context.authAccent.withValues(alpha: 0.5),
                      )
                    : null,
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
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: tonal ? 14.5 : 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: fg,
                            ),
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
      child: Container(height: 1, color: context.authBorder),
    );
    return Row(
      children: [
        line,
        Flexible(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                color: context.authMuted,
              ),
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
      color: context.authField,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.authBorder),
          ),
          // The label is centred on the button itself; the logo sits at the
          // start, so the text lines up with the button above it.
          child: Stack(
            alignment: Alignment.center,
            children: [
              const PositionedDirectional(
                start: 18,
                child: GoogleLogo(size: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 52,
                  vertical: 14,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: context.authText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
