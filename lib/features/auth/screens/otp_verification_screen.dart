import 'dart:async';
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
// 🔐 OTP VERIFICATION SCREEN — v3.0 Consistent Redesign
//
// Changes from v2:
//   ✅ Uses shared AuthBackground (no more duplicate)
//   ✅ Uses shared AuthBottomText (no more duplicate)
//   ✅ Uses shared HandleBar widget
//   ✅ Uses shared AuthSnackbar utility
//   ✅ Uses AuthConstants for all design tokens
//   ✅ Fixed FocusNode listener memory leak in _OtpBoxState
//   ✅ Fixed AnimatedBuilder → ListenableBuilder
//   ✅ Fixed duplicate _ parameter names
//   ✅ Added PopScope to prevent back during verification
//   ✅ Card radius, button radius/height match Login screen
//   ✅ Animation durations + intervals match Login screen
//
// Preserved:
//   ✅ All logic: OTP verify, shake, resend timer
//   ✅ Phone chip with Change link
//   ✅ Error collapse animation
//   ✅ TODO markers for backend hooks
// ============================================================

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpCtrl =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isError   = false;
  String _errorMsg = '';
  String _phone    = '';

  int _resendSecs  = 30;
  Timer? _resendTimer;
  bool _canResend  = false;

  late final AnimationController _entryCtrl;
  late final AnimationController _shakeCtrl;

  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _initAnimations();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!mounted) return;
      final extra = GoRouterState.of(context).extra;
      if (extra is String) setState(() => _phone = extra);
      _entryCtrl.forward();
      _startTimer();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _focusNodes[0].requestFocus();
      });
    });
  }

  void _initAnimations() {
    _entryCtrl = AnimationController(
      vsync: this,
      duration: AuthConstants.entryDuration,
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(
          AuthConstants.headerStart,
          AuthConstants.headerEnd,
          curve: Curves.easeOut,
        ),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.20),
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
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.30, 1.0, curve: Curves.easeOutCubic),
    ));

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -14.0), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: -14.0, end: 14.0), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: 14.0, end: -8.0), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeCtrl,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    for (final c in _otpCtrl) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _entryCtrl.dispose();
    _shakeCtrl.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _resendSecs = 30;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSecs--;
        if (_resendSecs <= 0) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  void _onOtpChanged(int i, String v) {
    if (_isError) setState(() => _isError = false);
    if (v.length == 1 && i < 5) {
      _focusNodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      _focusNodes[i - 1].requestFocus();
    }
    if (_otpCtrl.map((c) => c.text).join().length == 6) {
      Future.delayed(const Duration(milliseconds: 150), _verify);
    }
  }

  Future<void> _verify() async {
    final otp = _otpCtrl.map((c) => c.text).join();
    if (otp.length < 6 || _isLoading) return;
    HapticUtils.mediumImpact();
    for (final f in _focusNodes) {
      f.unfocus();
    }
    setState(() => _isLoading = true);
    try {
      // TODO: authProvider.verifyOTP(otp)
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      // TODO: bool isNewUser = await authProvider.checkIsNewUser()
      // TODO: replace with: context.go(isNewUser ? '/onboarding' : '/dashboard')
      HapticUtils.heavyImpact();
      context.go('/onboarding');
    } catch (_) {
      if (!mounted) return;
      HapticUtils.errorVibrate();
      _shakeCtrl.forward(from: 0);
      setState(() {
        _isError = true;
        _isLoading = false;
        _errorMsg = 'Incorrect OTP. Please try again.';
      });
      for (final c in _otpCtrl) {
        c.clear();
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    HapticUtils.lightImpact();
    // TODO: authProvider.resendOTP(_phone)
    for (final c in _otpCtrl) {
      c.clear();
    }
    setState(() {
      _isError = false;
      _errorMsg = '';
    });
    _startTimer();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNodes[0].requestFocus();
    });
    if (!mounted) return;
    AuthSnackbar.showSuccess(context, 'OTP sent again ✓');
  }

  String _fmt(String p) =>
      p.length == 10 ? '${p.substring(0, 5)} ${p.substring(5)}' : p;

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        backgroundColor: AuthConstants.scaffoldBg,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const AuthBackground(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: keyboardH > 0 ? keyboardH : 0,
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildFormCard(bottomPad),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: _entryCtrl,
      builder: (context, child) => FadeTransition(
        opacity: _headerOpacity,
        child: SlideTransition(
          position: _headerSlide,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    if (_isLoading) return;
                    HapticUtils.lightImpact();
                    context.pop();
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.brandDark,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Lock icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppTheme.primaryGlow,
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Verify your\nphone number',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit code to your number.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),

                // Phone chip — flag + number + Change
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                      AppTheme.brandPrimary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🇮🇳',
                          style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 7),
                      Text(
                        '+91 ${_fmt(_phone)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (_isLoading) return;
                          HapticUtils.lightImpact();
                          context.pop();
                        },
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
              24, 28, 24, 24 + bottomPad,
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
                SizedBox(height: AuthConstants.afterHandleBar),

                const Text(
                  'Enter the 6-digit code',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 20),

                // OTP boxes + shake
                FadeAnimation(
                  delayInMs: 260,
                  child: ListenableBuilder(
                    listenable: _shakeCtrl,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_shakeAnim.value, 0),
                      child: child,
                    ),
                    child: _OtpInputRow(
                      controllers: _otpCtrl,
                      focusNodes: _focusNodes,
                      isError: _isError,
                      onChanged: _onOtpChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Error message — collapse when hidden
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _isError ? 28 : 0,
                  child: _isError
                      ? Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AppTheme.error,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _errorMsg,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppTheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 22),

                // Verify button
                FadeAnimation(
                  delayInMs: 340,
                  child: _buildVerifyBtn(),
                ),
                const SizedBox(height: 20),

                // Resend row
                FadeAnimation(
                  delayInMs: 400,
                  child: _buildResendRow(),
                ),
                const SizedBox(height: 22),

                // Terms
                const FadeAnimation(
                  delayInMs: 460,
                  child: AuthBottomText(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Verify button ─────────────────────────────────────────
  Widget _buildVerifyBtn() {
    final otp = _otpCtrl.map((c) => c.text).join();
    final ok = otp.length == 6 && !_isError;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      height: AuthConstants.buttonHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ok
              ? [AppTheme.brandPrimary, const Color(0xFFFF6B84)]
              : [Colors.grey.shade200, Colors.grey.shade200],
        ),
        borderRadius: BorderRadius.circular(AuthConstants.buttonRadius),
        boxShadow: ok ? AppTheme.primaryGlow : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: ok ? _verify : null,
          borderRadius: BorderRadius.circular(AuthConstants.buttonRadius),
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
                  'Verify',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ok ? Colors.white : Colors.grey.shade400,
                    letterSpacing: 0.2,
                  ),
                ),
                if (ok) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Resend row ────────────────────────────────────────────
  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        GestureDetector(
          onTap: _canResend ? _resend : null,
          child: _canResend
              ? const Text(
            'Resend',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.brandPrimary,
            ),
          )
              : Text(
            'Resend in ${_resendSecs}s',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// OTP INPUT ROW — 6 animated boxes
// ══════════════════════════════════════════════════════════════
class _OtpInputRow extends StatelessWidget {
  const _OtpInputRow({
    required this.controllers,
    required this.focusNodes,
    required this.isError,
    required this.onChanged,
  });
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isError;
  final void Function(int index, String val) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
            (i) => _OtpBox(
          controller: controllers[i],
          focusNode: focusNodes[i],
          isError: isError,
          onChanged: (v) => onChanged(i, v),
        ),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isError,
    required this.onChanged,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isError;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;
  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _focusListener = () {
      if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
    };
    widget.focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: widget.isError
            ? const Color(0xFFFFF0F0)
            : _isFocused
            ? const Color(0xFFFDF2F4)
            : hasValue
            ? Colors.white
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isError
              ? AppTheme.error.withValues(alpha: 0.60)
              : _isFocused
              ? AppTheme.brandPrimary
              : hasValue
              ? AppTheme.brandPrimary.withValues(alpha: 0.30)
              : Colors.grey.shade200,
          width: _isFocused ? 2.0 : 1.5,
        ),
        boxShadow: _isFocused && !widget.isError
            ? [
          BoxShadow(
            color:
            AppTheme.brandPrimary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        onChanged: widget.onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: widget.isError ? AppTheme.error : AppTheme.brandDark,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}