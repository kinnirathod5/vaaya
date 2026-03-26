import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/auth_background.dart';
import '../../../../shared/widgets/auth_bottom_text.dart';
import '../../../../shared/widgets/auth_snackbar.dart';
import '../../../../shared/widgets/handle_bar.dart';

// ============================================================
// 📱 LOGIN SCREEN — v4.0 Consistent Redesign
//
// Changes from v3:
//   ✅ Uses shared AuthBackground (no more duplicate)
//   ✅ Uses shared AuthBottomText (no more duplicate)
//   ✅ Uses shared HandleBar widget
//   ✅ Uses shared AuthSnackbar utility
//   ✅ Uses AuthConstants for all design tokens
//   ✅ Fixed FocusNode listener memory leak
//   ✅ Fixed AnimatedBuilder → ListenableBuilder
//   ✅ Fixed duplicate _ parameter names
//   ✅ Removed unused _TrustPill widget
//   ✅ Card radius, button radius/height match OTP screen
//   ✅ Animation durations + intervals match OTP screen
//
// Preserved:
//   ✅ All logic: validation, OTP send, error handling
//   ✅ Guest sheet + feature rows
//   ✅ Keyboard handling + safe area + bounce scroll
//   ✅ TODO markers for backend hooks
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneCtrl  = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _isLoading    = false;
  bool _isValidPhone = false;

  late final AnimationController _entryCtrl;
  late final AnimationController _btnCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _btnScale;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: AuthConstants.entryDuration,
    );
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(
          AuthConstants.headerStart,
          AuthConstants.headerEnd,
          curve: Curves.easeOut,
        ),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
    ));

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(
          AuthConstants.contentStart,
          AuthConstants.contentEnd,
          curve: Curves.easeOut,
        ),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.30, 1.0, curve: Curves.easeOutCubic),
    ));

    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeIn),
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _entryCtrl.forward();
    });
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onPhoneChanged);
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
    _entryCtrl.dispose();
    _btnCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final valid = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length == 10;
    if (valid != _isValidPhone) {
      setState(() => _isValidPhone = valid);
      if (valid) {
        _pulseCtrl.repeat(reverse: true);
      } else {
        _pulseCtrl
          ..stop()
          ..reset();
      }
    }
  }

  Future<void> _onSendOTP() async {
    if (!_isValidPhone || _isLoading) return;
    HapticUtils.mediumImpact();
    _phoneFocus.unfocus();
    setState(() => _isLoading = true);
    await _btnCtrl.forward();
    await _btnCtrl.reverse();
    try {
      // TODO: authProvider.sendOTP('+91${_phoneCtrl.text.trim()}')
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      context.push('/otp', extra: _phoneCtrl.text.trim());
    } catch (_) {
      if (!mounted) return;
      AuthSnackbar.showError(context, 'Could not send OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AuthConstants.scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: keyboardH > 0 ? keyboardH : 0),
              child: Column(
                children: [
                  _buildHeroSection(),
                  _buildFormCard(bottomPad),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HERO SECTION
  // ══════════════════════════════════════════════════════════
  Widget _buildHeroSection() {
    return ListenableBuilder(
      listenable: _entryCtrl,
      builder: (context, child) => FadeTransition(
        opacity: _logoOpacity,
        child: SlideTransition(
          position: _logoSlide,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Brand icon with decorative rings ──────
                const _BrandIcon(),
                const SizedBox(height: 8),

                // ── App name ─────────────────────────────
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(children: [
                    TextSpan(
                      text: 'Banjara ',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandDark,
                        letterSpacing: 0.2,
                        height: 1.1,
                      ),
                    ),
                    TextSpan(
                      text: 'Vivah',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandPrimary,
                        letterSpacing: 0.2,
                        height: 1.1,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 4),
                Text(
                  'COMMUNITY MATRIMONY',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),

                // ── Headline ─────────────────────────────
                const Text(
                  'Find your',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    height: 1.05,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'perfect match.',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandPrimary,
                    height: 1.05,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Gradient underline accent
                ShaderMask(
                  shaderCallback: (rect) =>
                      AppTheme.brandGradient.createShader(rect),
                  child: Container(
                    width: 72,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Stats strip ──────────────────────────
                const _StatsStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FORM CARD
  // ══════════════════════════════════════════════════════════
  Widget _buildFormCard(double bottomPad) {
    return ListenableBuilder(
      listenable: _entryCtrl,
      builder: (context, child) => FadeTransition(
        opacity: _contentOpacity,
        child: SlideTransition(
          position: _contentSlide,
          child: Container(
            margin: const EdgeInsets.only(top: 28),
            padding: EdgeInsets.fromLTRB(
              24, 14, 24, bottomPad > 0 ? bottomPad : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AuthConstants.cardRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandPrimary
                      .withValues(alpha: AuthConstants.cardShadowAlpha),
                  blurRadius: AuthConstants.cardShadowBlur,
                  offset: const Offset(0, -6),
                ),
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: AuthConstants.cardBlackAlpha),
                  blurRadius: AuthConstants.cardBlackBlur,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                const HandleBar(),
                const SizedBox(height: 12),

                // Title row + secure badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign in',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.brandDark,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Enter your mobile to receive a one-time code.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const _SecureBadge(),
                  ],
                ),
                const SizedBox(height: 8),

                // Field label
                const Text(
                  'MOBILE NUMBER',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBDBDBD),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 5),

                // Phone input
                FadeAnimation(
                  delayInMs: 300,
                  child: _PhoneInputField(
                    controller: _phoneCtrl,
                    focusNode: _phoneFocus,
                    isValid: _isValidPhone,
                    onSubmitted: (_) => _onSendOTP(),
                  ),
                ),
                const SizedBox(height: 10),

                // OTP button
                FadeAnimation(
                  delayInMs: 380,
                  child: _buildOTPBtn(),
                ),
                const SizedBox(height: 10),

                // OR divider
                FadeAnimation(
                  delayInMs: 420,
                  child: Row(
                    children: [
                      Expanded(child: Divider(
                          color: Colors.grey.shade200, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'or',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(
                          color: Colors.grey.shade200, thickness: 1)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Guest button
                FadeAnimation(
                  delayInMs: 460,
                  child: _buildGuestBtn(),
                ),
                const SizedBox(height: 12),

                // Terms
                const FadeAnimation(
                  delayInMs: 500,
                  child: AuthBottomText(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Send OTP button ───────────────────────────────────────
  Widget _buildOTPBtn() {
    return ListenableBuilder(
      listenable: Listenable.merge([_btnCtrl, _pulseCtrl]),
      builder: (context, child) {
        final glowAlpha =
        _isValidPhone ? 0.18 + 0.16 * _pulseAnim.value : 0.0;
        final blurRadius =
        _isValidPhone ? 14.0 + 10.0 * _pulseAnim.value : 0.0;

        return Transform.scale(
          scale: _btnScale.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            width: double.infinity,
            height: AuthConstants.buttonHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isValidPhone
                    ? [const Color(0xFFE8395A), const Color(0xFFFF7190)]
                    : [Colors.grey.shade200, Colors.grey.shade200],
              ),
              borderRadius:
              BorderRadius.circular(AuthConstants.buttonRadius),
              boxShadow: _isValidPhone
                  ? [
                BoxShadow(
                  color: AppTheme.brandPrimary
                      .withValues(alpha: glowAlpha),
                  blurRadius: blurRadius,
                  offset: const Offset(0, 5),
                ),
              ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isValidPhone ? _onSendOTP : null,
                borderRadius:
                BorderRadius.circular(AuthConstants.buttonRadius),
                splashColor: Colors.white.withValues(alpha: 0.12),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Send OTP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: _isValidPhone
                              ? Colors.white
                              : Colors.grey.shade400,
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: _isValidPhone
                            ? const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Guest button ──────────────────────────────────────────
  Widget _buildGuestBtn() {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _GuestSheet(
            onGuest: () {
              Navigator.pop(context);
              HapticUtils.mediumImpact();
              // TODO: authProvider.setGuestMode(true)
              context.go('/dashboard');
            },
            onLogin: () {
              Navigator.pop(context);
              _phoneFocus.requestFocus();
            },
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(AuthConstants.buttonRadius),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.explore_outlined,
                size: 15,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Explore as Guest',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '3 free',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BRAND ICON — dashed outer ring + halo ring + gradient icon
// ══════════════════════════════════════════════════════════════
class _BrandIcon extends StatelessWidget {
  const _BrandIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer dashed ring
          CustomPaint(
            size: const Size(80, 80),
            painter: _DashedRingPainter(
              color: AppTheme.brandPrimary.withValues(alpha: 0.14),
              strokeWidth: 1.5,
            ),
          ),
          // Middle halo ring
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.07),
            ),
          ),
          // Inner gradient icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.brandGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.spa_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter({
    required this.color,
    required this.strokeWidth,
  });
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    const dashCount = 28;
    const gap = math.pi * 2 / dashCount;
    const dashLen = gap * 0.52;
    for (int i = 0; i < dashCount; i++) {
      final start = i * gap - math.pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashLen,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════════
// STATS STRIP — 50K+ Families · 4.8★ Rating · Pan India
// ══════════════════════════════════════════════════════════════
class _StatsStrip extends StatelessWidget {
  const _StatsStrip();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatItem(value: '50K+', label: 'Families'),
        _StatDivider(),
        _StatItem(value: '4.8★', label: 'Rating'),
        _StatDivider(),
        _StatItem(value: 'All', label: 'Pan India'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.brandDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade300,
            Colors.grey.shade100,
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SECURE BADGE
// ══════════════════════════════════════════════════════════════
class _SecureBadge extends StatelessWidget {
  const _SecureBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.success.withValues(alpha: 0.18),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 11, color: AppTheme.success),
          SizedBox(width: 4),
          Text(
            'Secure',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PHONE INPUT FIELD
// ══════════════════════════════════════════════════════════════
class _PhoneInputField extends StatefulWidget {
  const _PhoneInputField({
    required this.controller,
    required this.focusNode,
    required this.isValid,
    required this.onSubmitted,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isValid;
  final ValueChanged<String> onSubmitted;

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
  bool _hasFocus = false;
  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _focusListener = () {
      if (mounted) setState(() => _hasFocus = widget.focusNode.hasFocus);
    };
    widget.focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusListener);
    super.dispose();
  }

  Color get _borderColor {
    if (widget.isValid) return AppTheme.success.withValues(alpha: 0.55);
    if (_hasFocus) return AppTheme.brandPrimary.withValues(alpha: 0.60);
    return Colors.grey.shade200;
  }

  Color get _bgColor {
    if (widget.isValid) return const Color(0xFFF0FDF4);
    if (_hasFocus) return const Color(0xFFFFF5F7);
    return Colors.grey.shade50;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: (widget.isValid || _hasFocus)
            ? [
          BoxShadow(
            color: (widget.isValid
                ? AppTheme.success
                : AppTheme.brandPrimary)
                .withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          // Country prefix
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 17)),
                const SizedBox(width: 6),
                Text(
                  '+91',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 15,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
          // Number input
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onSubmitted: widget.onSubmitted,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandDark,
                letterSpacing: 2.5,
              ),
              decoration: InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                suffixIcon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isValid
                      ? const Padding(
                    key: ValueKey('check'),
                    padding: EdgeInsets.all(14),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.success,
                      size: 22,
                    ),
                  )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GUEST BOTTOM SHEET
// ══════════════════════════════════════════════════════════════
class _GuestSheet extends StatelessWidget {
  const _GuestSheet({required this.onGuest, required this.onLogin});
  final VoidCallback onGuest;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AuthConstants.cardRadius),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, 24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HandleBar(),
          const SizedBox(height: 22),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.primaryGlow,
            ),
            child: const Icon(
              Icons.explore_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Guest Mode',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.brandDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore without signing up —\nbut some features will be limited.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const _FeatureRow(
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
            text: 'View the first 3 profiles in full',
            ok: true,
          ),
          const SizedBox(height: 10),
          const _FeatureRow(
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
            text: 'Browse Home and Matches screens',
            ok: true,
          ),
          const SizedBox(height: 10),
          const _FeatureRow(
            icon: Icons.lock_rounded,
            color: Color(0xFFBDBDBD),
            text: 'Send interests or start a chat',
            ok: false,
          ),
          const SizedBox(height: 10),
          const _FeatureRow(
            icon: Icons.lock_rounded,
            color: Color(0xFFBDBDBD),
            text: 'Login required after the 4th profile',
            ok: false,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: AuthConstants.buttonHeight,
            child: ElevatedButton(
              onPressed: onGuest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(AuthConstants.buttonRadius),
                ),
              ),
              child: const Text(
                'Explore — 3 profiles free',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onLogin,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Want to sign in instead? ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Text(
                    'Enter number',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.text,
    required this.ok,
  });
  final IconData icon;
  final Color color;
  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ok ? AppTheme.brandDark : const Color(0xFFBDBDBD),
            ),
          ),
        ),
      ],
    );
  }
}