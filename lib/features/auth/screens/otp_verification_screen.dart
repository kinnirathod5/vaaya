import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../shared/widgets/primary_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, this.phoneNumber = '+91 98765 43210'});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();

  int _resendTimer = 30;
  Timer? _timer;
  bool _isOtpValid = false;
  final int _otpLength = 4;

  // 🔥 FIX 1: Infinite loop rokne ke liye previous text track karenge
  String _previousOtpText = '';

  @override
  void initState() {
    super.initState();
    _startTimer();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) FocusScope.of(context).requestFocus(_otpFocus);
    });

    _otpController.addListener(() {
      final text = _otpController.text;

      // 🔥 FIX 1: Agar text change nahi hua (sirf cursor hila hai), toh wapas jao!
      if (text == _previousOtpText) return;
      _previousOtpText = text;

      if (text.length == _otpLength && !_isOtpValid) {
        HapticUtils.heavyImpact();
        setState(() => _isOtpValid = true);
        FocusScope.of(context).unfocus();
      } else if (text.length < _otpLength && _isOtpValid) {
        setState(() => _isOtpValid = false);
      } else {
        if (text.isNotEmpty) HapticUtils.lightImpact();
      }

      // Ab yeh setState ekdum safe hai, app crash nahi hoga
      setState(() {});
    });
  }

  void _startTimer() {
    setState(() => _resendTimer = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0 && mounted) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_isOtpValid) {
      HapticUtils.heavyImpact();
      FocusScope.of(context).unfocus();

      // 🚀 OTP Sahi hai -> Chalo Account Banane!
      context.go('/onboarding');

    } else {
      HapticUtils.errorVibrate();
      CustomToast.showError(context, 'Invalid OTP. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.bgScaffold,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // ✨ AMBIENT GLOW
            Positioned(
              top: -50, right: -50,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(width: 250, height: 250, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x26F23B5F))),
              ),
            ),
            Positioned(
              bottom: 100, left: -50,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(width: 200, height: 200, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x1A448AFF))),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    // 🔙 Back Button
                    GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        context.pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.softShadow,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.brandDark, size: 18),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 🔤 Title & Subtitle
                    Text('Verify your\nnumber.', style: AppTheme.lightTheme.textTheme.displayLarge),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade500),
                        children: [
                          const TextSpan(text: 'We\'ve sent a 4-digit code to\n'),
                          TextSpan(text: widget.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                          const TextSpan(text: '  '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                HapticUtils.lightImpact();
                                context.pop();
                              },
                              child: const Text('Edit', style: TextStyle(color: AppTheme.brandPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    // 🔐 THE MAGIC OTP BOXES (Rock Solid Version)
                    SizedBox(
                      height: 70,
                      child: Stack(
                        children: [
                          // UI Boxes (Neeche rahenge)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(_otpLength, (index) {
                              bool isFilled = _otpController.text.length > index;
                              bool isActive = _otpFocus.hasFocus && _otpController.text.length == index;
                              String digit = isFilled ? _otpController.text[index] : '';

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                  color: isFilled || isActive ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isActive ? AppTheme.brandPrimary : (isFilled ? Colors.transparent : Colors.grey.shade300),
                                    width: isActive ? 2 : 1,
                                  ),
                                  boxShadow: isFilled || isActive ? AppTheme.softShadow : [],
                                ),
                                child: Center(
                                  child: Text(digit, style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.brandDark)),
                                ),
                              );
                            }),
                          ),

                          // 🔥 FIX 2: True Invisible TextField (Upar rahega, taps catch karega)
                          Positioned.fill(
                            child: TextField(
                              controller: _otpController,
                              focusNode: _otpFocus,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              maxLength: _otpLength,
                              cursorColor: Colors.transparent, // Invisible cursor
                              style: const TextStyle(color: Colors.transparent, fontSize: 1), // Invisible text
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none, // 🔥 FIX: Saare borders forcefully hataye
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                filled: false, // 🔥 MAIN FIX: White background box ko transparent kiya
                                fillColor: Colors.transparent,
                                counterText: '', // Hide 0/4 text
                              ),
                              autocorrect: false,
                              enableSuggestions: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ⏱️ Resend Timer Logic
                    Center(
                      child: _resendTimer > 0
                          ? Text('Didn\'t receive code? Resend in 00:${_resendTimer.toString().padLeft(2, '0')}', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade500))
                          : GestureDetector(
                        onTap: () {
                          HapticUtils.mediumImpact();
                          _startTimer();
                          CustomToast.showSuccess(context, 'OTP Resent Successfully!');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(color: AppTheme.brandPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Resend OTP', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: AppTheme.brandPrimary)),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 🔘 Primary Button
                    PrimaryButton(
                      text: 'Verify Account',
                      isEnabled: _isOtpValid,
                      onTap: _verifyOtp,
                    ),

                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}