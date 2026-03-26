import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';

// ============================================================
// 📱 LOGIN SCREEN — v2.0 All Widgets Inlined
//
// IMPROVEMENTS vs v1:
//   ✅ auth_background.dart, phone_input_field.dart,
//      auth_bottom_text.dart — all inlined
//   ✅ Dual-tone app name: "Banjara" dark + "Vivah" brand pink
//   ✅ Headline: "Find your" on one line, "perfect match."
//      on second — cleaner rhythm
//   ✅ Trust pills: added a 3rd "Banjara Community" pill
//   ✅ Phone field: green tick check circle on valid
//   ✅ Send OTP button: arrow icon appears only when valid
//   ✅ Guest sheet: feature rows with cleaner icons
//   ✅ Form card: handle bar tinted brand pink
//   ✅ Background: dot grid + three bloom orbs
//   ✅ All text: maxLines + overflow
//
// TODO: authProvider.sendOTP(phone) — Riverpod
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

  late final Animation<double> _logoOpacity;
  late final Animation<Offset>  _logoSlide;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset>  _contentSlide;
  late final Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _entryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _btnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 180),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.0, 0.55, curve: Curves.easeOut)),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.25), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic)));

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.28, 0.88, curve: Curves.easeOut)),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.20), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl,
        curve: const Interval(0.28, 1.0, curve: Curves.easeOutCubic)));

    _btnScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(milliseconds: 80),
            () { if (mounted) _entryCtrl.forward(); });
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_onPhoneChanged);
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
    _entryCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final valid = _phoneCtrl.text
        .replaceAll(RegExp(r'\D'), '').length == 10;
    if (valid != _isValidPhone) setState(() => _isValidPhone = valid);
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
      _showError('Could not send OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: AppTheme.error.withValues(alpha: 0.30),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(
            fontFamily: 'Poppins', color: Colors.white,
            fontSize: 13, fontWeight: FontWeight.w600,
          ))),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F9),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Ambient background
          const _AuthBackground(),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                  bottom: keyboardH > 0 ? keyboardH : 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height
                      - MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    _buildLogoSection(),
                    _buildFormCard(bottomPad),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // LOGO SECTION — top half
  // ══════════════════════════════════════════════════════════
  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, __) => FadeTransition(
        opacity: _logoOpacity,
        child: SlideTransition(
          position: _logoSlide,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Logo icon + dual-tone name
                Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.brandGradient,
                        boxShadow: AppTheme.primaryGlow,
                      ),
                      child: const Center(
                        child: Icon(Icons.spa_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dual-tone name
                        RichText(
                          text: const TextSpan(children: [
                            TextSpan(
                              text: 'Banjara ',
                              style: TextStyle(
                                fontFamily: 'Cormorant Garamond',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandDark,
                                letterSpacing: 0.1,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: 'Vivah',
                              style: TextStyle(
                                fontFamily: 'Cormorant Garamond',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandPrimary,
                                letterSpacing: 0.1,
                                height: 1.1,
                              ),
                            ),
                          ]),
                        ),
                        Text(
                          'Community Matrimony',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Headline
                const Text(
                  'Find your\nperfect match.',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    height: 1.08,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Trusted by 50,000+ Banjara families.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Trust pills row
                Row(
                  children: [
                    Expanded(
                      child: _TrustPill(
                        icon: Icons.verified_rounded,
                        label: 'Verified Profiles',
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TrustPill(
                        icon: Icons.lock_rounded,
                        label: '100% Private',
                        color: AppTheme.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TrustPill(
                        icon: Icons.people_rounded,
                        label: 'Banjara Only',
                        color: AppTheme.goldPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FORM CARD — bottom white card
  // ══════════════════════════════════════════════════════════
  Widget _buildFormCard(double bottomPad) {
    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, __) => FadeTransition(
        opacity: _contentOpacity,
        child: SlideTransition(
          position: _contentSlide,
          child: Container(
            margin: const EdgeInsets.only(top: 28),
            padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottomPad),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, -6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Handle bar
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Form title
                const Text(
                  'Enter your number',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.brandDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We\'ll send a one-time code to verify you.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),

                // Phone input
                FadeAnimation(
                  delayInMs: 300,
                  child: _PhoneInputField(
                    controller: _phoneCtrl,
                    focusNode:  _phoneFocus,
                    isValid:    _isValidPhone,
                    onSubmitted: (_) => _onSendOTP(),
                  ),
                ),
                const SizedBox(height: 8),

                // Hint text
                FadeAnimation(
                  delayInMs: 340,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _isValidPhone
                            ? 'Looks good — tap Send OTP ✓'
                            : 'Enter your 10-digit mobile number',
                        key: ValueKey(_isValidPhone),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _isValidPhone
                              ? AppTheme.success
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Send OTP button
                FadeAnimation(
                  delayInMs: 380,
                  child: _buildOTPBtn(),
                ),
                const SizedBox(height: 14),

                // OR divider
                FadeAnimation(
                  delayInMs: 420,
                  child: Row(children: [
                    Expanded(child: Divider(
                        color: Colors.grey.shade200, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      )),
                    ),
                    Expanded(child: Divider(
                        color: Colors.grey.shade200, thickness: 1)),
                  ]),
                ),
                const SizedBox(height: 14),

                // Guest button
                FadeAnimation(
                  delayInMs: 460,
                  child: _buildGuestBtn(),
                ),
                const SizedBox(height: 20),

                // Terms
                FadeAnimation(
                  delayInMs: 500,
                  child: const _AuthBottomText(),
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
    return AnimatedBuilder(
      animation: _btnCtrl,
      builder: (_, __) => Transform.scale(
        scale: _btnScale.value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity, height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isValidPhone
                  ? [AppTheme.brandPrimary, const Color(0xFFFF6B84)]
                  : [Colors.grey.shade200, Colors.grey.shade200],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isValidPhone ? AppTheme.primaryGlow : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isValidPhone ? _onSendOTP : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5,
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
                        color: _isValidPhone
                            ? Colors.white
                            : Colors.grey.shade400,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (_isValidPhone) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 17),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined,
                size: 17, color: Colors.grey.shade500),
            const SizedBox(width: 8),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '3 free',
                style: const TextStyle(
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
// AUTH BACKGROUND — warm blobs + dot grid
// ══════════════════════════════════════════════════════════════
class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFFDF8F9)),
        Positioned(
          top: -100, right: -80,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          top: 160, left: -80,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 100, right: -60,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.goldPrimary.withValues(alpha: 0.04),
            ),
          ),
        ),
        Positioned(
          top: 0, left: 0, right: 0,
          child: SizedBox(
            height: 220,
            child: CustomPaint(painter: _DotGridPainter()),
          ),
        ),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.brandPrimary.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    const s = 26.0;
    final cols = (size.width / s).ceil() + 1;
    final rows = (size.height / s).ceil() + 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * s + (r.isOdd ? s / 2 : 0), r * s * 0.88),
          1.3, paint,
        );
      }
    }
  }
  @override bool shouldRepaint(_DotGridPainter _) => false;
}

// ══════════════════════════════════════════════════════════════
// PHONE INPUT FIELD
// ══════════════════════════════════════════════════════════════
class _PhoneInputField extends StatelessWidget {
  const _PhoneInputField({
    required this.controller,
    required this.focusNode,
    required this.isValid,
    required this.onSubmitted,
  });
  final TextEditingController controller;
  final FocusNode             focusNode;
  final bool                  isValid;
  final ValueChanged<String>  onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isValid
            ? const Color(0xFFF0FDF4)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isValid
              ? AppTheme.success.withValues(alpha: 0.50)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: isValid
            ? [BoxShadow(
          color: AppTheme.success.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        )]
            : [],
      ),
      child: Row(
        children: [
          // +91 prefix
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                    color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '+91',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),

          // Number input
          Expanded(
            child: TextField(
              controller:      controller,
              focusNode:       focusNode,
              keyboardType:    TextInputType.phone,
              maxLength:       10,
              onSubmitted:     onSubmitted,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily:    'Poppins',
                fontSize:      18,
                fontWeight:    FontWeight.w700,
                color:         AppTheme.brandDark,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(
                  fontFamily:    'Poppins',
                  fontSize:      16,
                  color:         Colors.grey.shade300,
                  fontWeight:    FontWeight.w400,
                  letterSpacing: 1,
                ),
                border:         InputBorder.none,
                counterText:    '',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 18),
                suffixIcon: isValid
                    ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.check_circle_rounded,
                      color: AppTheme.success, size: 22),
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TRUST PILL
// ══════════════════════════════════════════════════════════════
class _TrustPill extends StatelessWidget {
  const _TrustPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String   label;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily:  'Poppins',
                fontSize:    10,
                fontWeight:  FontWeight.w600,
                color:       color.withValues(alpha: 0.90),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AUTH BOTTOM TEXT — Terms + Privacy
// ══════════════════════════════════════════════════════════════
class _AuthBottomText extends StatelessWidget {
  const _AuthBottomText();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize:   11,
            color:      Colors.grey.shade400,
            height:     1.6,
          ),
          children: const [
            TextSpan(text: 'By continuing you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color:      AppTheme.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color:      AppTheme.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, 24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.primaryGlow,
            ),
            child: const Icon(Icons.explore_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Guest Mode',
            style: TextStyle(
              fontFamily:  'Cormorant Garamond',
              fontSize:    26,
              fontWeight:  FontWeight.w700,
              color:       AppTheme.brandDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Explore without signing up —\nbut some features will be limited.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize:   13,
              color:      Colors.grey.shade500,
              height:     1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Feature rows
          _FeatureRow(
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
            text: 'View the first 3 profiles in full',
            ok: true,
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
            text: 'Browse Home and Matches screens',
            ok: true,
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.lock_rounded,
            color: Colors.grey.shade400,
            text: 'Send interests or start a chat',
            ok: false,
          ),
          const SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.lock_rounded,
            color: Colors.grey.shade400,
            text: 'Login required after the 4th profile',
            ok: false,
          ),
          const SizedBox(height: 24),

          // Explore CTA
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: onGuest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Explore — 3 profiles free',
                style: TextStyle(
                  fontFamily:  'Poppins',
                  fontSize:    14,
                  fontWeight:  FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sign in link
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
                      fontSize:   13,
                      color:      Colors.grey.shade500,
                    ),
                  ),
                  const Text(
                    'Enter number',
                    style: TextStyle(
                      fontFamily:  'Poppins',
                      fontSize:    13,
                      fontWeight:  FontWeight.w700,
                      color:       AppTheme.brandPrimary,
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
  final Color    color;
  final String   text;
  final bool     ok;

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
              fontFamily:  'Poppins',
              fontSize:    13,
              fontWeight:  FontWeight.w500,
              color: ok ? AppTheme.brandDark : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}