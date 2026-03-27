import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/constants/onboarding_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/animations/fade_animation.dart';
import '../../../shared/widgets/auth_snackbar.dart';
import '../../../shared/widgets/custom_chip.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/step_progress_header.dart';

// ============================================================
// 🪷 ACCOUNT CREATION SCREEN — v5.0
//
// Fixes over v4 (screenshots review):
//   ✅ FIX 9 — CustomChip pill → borderRadius: 10
//              GestureDetector → Material + InkWell
//   ✅ FIX 10 — _dobTouched = true by default
//              Picker shows valid date — no need to touch
//   ✅ FIX 11 — Welcome card fontSize: 26 → 22 + textAlign center
//              Long names were wrapping 🎉 to next line
//
// Fixes over v3:
//   ✅ FIX 1 — ALL CAPS _FieldLabel → sentence case
//              'FIRST NAME' → 'First name', letterSpacing 1.2→0.3
//   ✅ FIX 2 — _GenderCard GestureDetector → Material + InkWell
//              Proper ripple on gender selection
//   ✅ FIX 3 — _CelebrationOverlay AnimatedBuilder duplicate _ param
//              builder: (_, _) → builder: (_, __) — compile fix
//   ✅ FIX 4 — Photo card GestureDetector → Material + InkWell
//              Ripple + clipBehavior for rounded corners
//   ✅ FIX 5 — Memory leak: removeListener added in dispose()
//              _firstCtrl + _lastCtrl listeners properly cleaned up
//   ✅ FIX 6 — _StepTitle fontSize: 34 → 30
//              Consistent with OTP/Login auth screens
//   ✅ FIX 7 — Height display fontSize: 52 w900 → 44 w800
//              Less cramped, more breathing room
//   ✅ FIX 8 — Photo GestureDetector → InkWell(onTap: null when uploaded)
//              InkWell null onTap = auto-disabled, no ripple when done
//
// Already good (preserved):
//   ✅ Accurate age calc — _calcAge() accounts for month+day
//   ✅ _isNavigating spinner on final step
//   ✅ AuthSnackbar validation messages per step
//   ✅ Gender-aware preview photo via AppAssets
//   ✅ OnboardingConstants for all layout/animation tokens
//
// TODO: onboardingProvider → profileRepository.createProfile()
// ============================================================

// ──────────────────────────────────────────────────────────────
// CONSTANTS
// ──────────────────────────────────────────────────────────────

const _totalSteps = 6;

const _stepMeta = <Map<String, String>>[
  {'emoji': '👤', 'label': 'Name',      'hint': 'Let\'s start with who you are.'},
  {'emoji': '🌸', 'label': 'Gender',    'hint': 'One tap — helps us personalise.'},
  {'emoji': '🎂', 'label': 'Birthday',  'hint': 'Every great match has perfect timing.'},
  {'emoji': '📏', 'label': 'Height',    'hint': 'Almost there, keep going!'},
  {'emoji': '🤝', 'label': 'Community', 'hint': 'Your roots shape your identity.'},
  {'emoji': '📸', 'label': 'Photo',     'hint': 'Last step — the VIP Lounge awaits!'},
];

const _forOptions = [
  'Myself', 'Son', 'Daughter', 'Brother', 'Sister', 'Relative',
];

const _gotraList = [
  'Rathod', 'Chavan', 'Pawar', 'Jadhav',
  'Ade', 'Naik', 'Muqayya', 'Gormati',
];

// ──────────────────────────────────────────────────────────────
// TOP-LEVEL HELPERS
// ──────────────────────────────────────────────────────────────

/// Accurate age calculation — accounts for month and day.
int _calcAge(DateTime dob) {
  final now = DateTime.now();
  int age = now.year - dob.year;
  if (now.month < dob.month ||
      (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}

// ──────────────────────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────────────────────

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen>
    with TickerProviderStateMixin {

  final _pageCtrl = PageController();
  int  _step = 0;
  bool _isNavigating = false;

  // Step 1
  String _profileFor = '';
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();

  // Step 2
  String _gender = '';

  // Step 3
  DateTime _dob = DateTime(2000, 1, 1);
  bool _dobTouched = true;  // FIX: default true — picker always shows valid date

  // Step 4
  int _feet = 5, _inches = 4;

  // Step 5
  String _gotra = '';

  // Step 6
  bool _photoUploaded = false;
  int  _scanStep = 0;

  // Celebration overlay
  bool _celebrate = false;

  // ── FIX 5: Store listener references for proper cleanup ───
  late final VoidCallback _firstListener;
  late final VoidCallback _lastListener;

  // ── Computed helpers ──────────────────────────────────────

  String get _firstName {
    final n = _firstCtrl.text.trim();
    return n.isEmpty ? '' : n.split(' ').first;
  }

  bool get _canNext {
    switch (_step) {
      case 0: return _profileFor.isNotEmpty &&
          _firstCtrl.text.trim().length >= 2 &&
          _lastCtrl.text.trim().length >= 2;
      case 1: return _gender.isNotEmpty;
      case 2: return _dobTouched;
      case 3: return true;
      case 4: return _gotra.isNotEmpty;
      case 5: return _photoUploaded && _scanStep == 2;
      default: return false;
    }
  }

  String get _validationMessage {
    switch (_step) {
      case 0:
        if (_profileFor.isEmpty) return 'Select who this profile is for';
        return 'Enter at least 2 characters for both names';
      case 1: return 'Please select your gender to continue';
      case 2: return 'Tap the date picker to set your birthday';
      case 3: return '';
      case 4: return 'Please select your Gotra to continue';
      case 5: return 'Upload and verify your photo to continue';
      default: return 'Please complete this step to continue';
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ── FIX 5: Store listeners so they can be removed ────────
    _firstListener = () => setState(() {});
    _lastListener  = () => setState(() {});
    _firstCtrl.addListener(_firstListener);
    _lastCtrl.addListener(_lastListener);
  }

  @override
  void dispose() {
    // ── FIX 5: Remove listeners — prevents memory leak ───────
    _firstCtrl.removeListener(_firstListener);
    _lastCtrl.removeListener(_lastListener);
    _pageCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────

  void _next() {
    if (!_canNext) {
      HapticUtils.errorVibrate();
      if (_validationMessage.isNotEmpty) {
        AuthSnackbar.showError(context, _validationMessage);
      }
      return;
    }
    FocusScope.of(context).unfocus();
    if (_step < _totalSteps - 1) {
      HapticUtils.lightImpact();
      setState(() => _step++);
      _pageCtrl.animateToPage(
        _step,
        duration: OnboardingConstants.pageTransitionDuration,
        curve:    OnboardingConstants.pageTransitionCurve,
      );
    } else {
      HapticUtils.heavyImpact();
      setState(() {
        _celebrate    = true;
        _isNavigating = true;
      });
      Future.delayed(OnboardingConstants.confettiDuration, () {
        if (mounted) context.go('/dashboard');
      });
    }
  }

  void _prev() {
    FocusScope.of(context).unfocus();
    if (_step > 0) {
      HapticUtils.lightImpact();
      setState(() => _step--);
      _pageCtrl.animateToPage(
        _step,
        duration: OnboardingConstants.pageTransitionDuration,
        curve:    OnboardingConstants.pageTransitionCurve,
      );
    } else {
      context.pop();
    }
  }

  void _onPhotoTap() {
    if (_photoUploaded) return;
    HapticUtils.mediumImpact();
    setState(() { _photoUploaded = true; _scanStep = 1; });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _scanStep = 2);
        HapticUtils.heavyImpact();
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AuthConstants.scaffoldBg,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            _AmbientGlow(step: _step),

            SafeArea(
              child: Column(
                children: [
                  StepProgressHeader(
                    current: _step,
                    total:   _totalSteps,
                    meta:    _stepMeta,
                    onBack:  _prev,
                  ),

                  _HintBanner(
                    key:  ValueKey(_step),
                    text: _stepMeta[_step]['hint']!,
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageCtrl,
                      physics:    const NeverScrollableScrollPhysics(),
                      children: [
                        _Step1Name(
                          profileFor:   _profileFor,
                          firstCtrl:    _firstCtrl,
                          lastCtrl:     _lastCtrl,
                          onForChanged: (v) =>
                              setState(() => _profileFor = v),
                        ),
                        _Step2Gender(
                          gender:    _gender,
                          firstName: _firstName,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        _Step3Birthday(
                          dob:       _dob,
                          touched:   _dobTouched,
                          firstName: _firstName,
                          isFemale:  _gender == 'Female',
                          onChanged: (d) => setState(() {
                            _dob        = d;
                            _dobTouched = true;
                          }),
                        ),
                        _Step4Height(
                          feet:            _feet,
                          inches:          _inches,
                          firstName:       _firstName,
                          isFemale:        _gender == 'Female',
                          onFeetChanged:   (v) => setState(() => _feet   = v),
                          onInchesChanged: (v) => setState(() => _inches = v),
                        ),
                        _Step5Community(
                          gotra:          _gotra,
                          firstName:      _firstName,
                          onGotraChanged: (v) =>
                              setState(() => _gotra = v),
                        ),
                        _Step6Photo(
                          uploaded:   _photoUploaded,
                          scanStep:   _scanStep,
                          firstName:  _firstName,
                          isFemale:   _gender == 'Female',
                          onPhotoTap: _onPhotoTap,
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      OnboardingConstants.stepHorizontalPad,
                      OnboardingConstants.buttonTopPad,
                      OnboardingConstants.stepHorizontalPad,
                      bottomPad + OnboardingConstants.buttonBottomPad,
                    ),
                    child: Stack(
                      children: [
                        PrimaryButton(
                          text: _step == _totalSteps - 1
                              ? 'Enter VIP Lounge'
                              : 'Continue',
                          icon: _step == _totalSteps - 1
                              ? Icons.workspace_premium_rounded
                              : null,
                          trailingIcon: _step < _totalSteps - 1 && _canNext
                              ? Icons.arrow_forward_rounded
                              : null,
                          isEnabled: _canNext,
                          isLoading: _isNavigating,
                          height:    AuthConstants.buttonHeight,
                          onTap:     _next,
                        ),
                        if (!_canNext && _validationMessage.isNotEmpty)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticUtils.errorVibrate();
                                AuthSnackbar.showError(
                                    context, _validationMessage);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_celebrate)
              _CelebrationOverlay(firstName: _firstName),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AMBIENT GLOW
// ══════════════════════════════════════════════════════════════
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: OnboardingConstants.ambientGlowDuration,
      curve:    OnboardingConstants.ambientGlowCurve,
      top:   step.isOdd ? 180 : -60,
      left:  step.isEven ? -60 : null,
      right: step.isOdd  ? -60 : null,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(
          width: 240, height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.brandPrimary.withValues(alpha: 0.09),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HINT BANNER
// ══════════════════════════════════════════════════════════════
class _HintBanner extends StatelessWidget {
  const _HintBanner({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: OnboardingConstants.hintBannerDuration,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.22),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Padding(
        key: ValueKey(text),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize:   12,
            color:      AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SHARED HELPERS
// ══════════════════════════════════════════════════════════════

class _StepTitle extends StatelessWidget {
  const _StepTitle({required this.title, this.subtitle});
  final String  title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily:    'Cormorant Garamond',
            // ── FIX 6: fontSize 34 → 30 — consistent with auth screens ─
            fontSize:      30,
            fontWeight:    FontWeight.w700,
            color:         AppTheme.brandDark,
            height:        1.15,
            letterSpacing: -0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize:   13,
              color:      AppTheme.textSecondary,
              height:     1.4,
            ),
          ),
        ],
      ],
    );
  }
}

// ── FIX 1: Sentence case + reduced letterSpacing ─────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily:    'Poppins',
        fontSize:      11,
        fontWeight:    FontWeight.w700,
        color:         AppTheme.textHint,
        letterSpacing: 0.3, // ← FIX 1: was 1.2 — ALL CAPS ke saath harsh
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STEP 1 — Profile for + name
// ══════════════════════════════════════════════════════════════
class _Step1Name extends StatelessWidget {
  const _Step1Name({
    required this.profileFor,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.onForChanged,
  });
  final String profileFor;
  final TextEditingController firstCtrl;
  final TextEditingController lastCtrl;
  final ValueChanged<String>  onForChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FadeAnimation(
            delayInMs: 0,
            child: _StepTitle(
              title:    'Let\'s start\nwith the basics.',
              subtitle: 'Genuine details help find genuine matches.',
            ),
          ),
          const SizedBox(height: 28),

          // ── FIX 1: sentence case ─────────────────────────
          const FadeAnimation(
            delayInMs: 80,
            child: _FieldLabel('Profile created for'), // was: 'PROFILE CREATED FOR'
          ),
          const SizedBox(height: 12),
          FadeAnimation(
            delayInMs: 120,
            child: Wrap(
              spacing: 10, runSpacing: 10,
              children: _forOptions.map((o) => CustomChip(
                label: o,
                isSelected: profileFor == o,
                onTap: () {
                  HapticUtils.selectionClick();
                  onForChanged(o);
                },
              )).toList(),
            ),
          ),
          const SizedBox(height: 26),

          const FadeAnimation(
            delayInMs: 180,
            child: _FieldLabel('First name'), // was: 'FIRST NAME'
          ),
          const SizedBox(height: 10),
          FadeAnimation(
            delayInMs: 220,
            child: CustomTextField(hintText: 'e.g. Rahul', controller: firstCtrl),
          ),
          const SizedBox(height: 18),

          const FadeAnimation(
            delayInMs: 260,
            child: _FieldLabel('Last name'), // was: 'LAST NAME'
          ),
          const SizedBox(height: 10),
          FadeAnimation(
            delayInMs: 300,
            child: CustomTextField(hintText: 'e.g. Rathod', controller: lastCtrl),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STEP 2 — Gender cards
// ══════════════════════════════════════════════════════════════
class _Step2Gender extends StatelessWidget {
  const _Step2Gender({
    required this.gender,
    required this.firstName,
    required this.onChanged,
  });
  final String gender;
  final String firstName;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
        OnboardingConstants.stepHorizontalPad,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeAnimation(
            delayInMs: 0,
            child: _StepTitle(
              title: firstName.isNotEmpty
                  ? 'Who are you,\n$firstName?'
                  : 'Who are you?',
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: FadeAnimation(
              delayInMs: 100,
              child: Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      emoji:      '👨',
                      title:      'Male',
                      isSelected: gender == 'Male',
                      onTap: () {
                        HapticUtils.selectionClick();
                        onChanged('Male');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderCard(
                      emoji:      '👩',
                      title:      'Female',
                      isSelected: gender == 'Female',
                      onTap: () {
                        HapticUtils.selectionClick();
                        onChanged('Female');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── FIX 2: GestureDetector → Material + InkWell on gender card ─
class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.emoji,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final bool   isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
          OnboardingConstants.genderCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
            OnboardingConstants.genderCardRadius),
        splashColor: AppTheme.brandPrimary.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: OnboardingConstants.genderCardDuration,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.brandPrimary.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(
                OnboardingConstants.genderCardRadius),
            border: Border.all(
              color: isSelected
                  ? AppTheme.brandPrimary
                  : Colors.grey.shade200,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [BoxShadow(
              color:      AppTheme.brandPrimary.withValues(alpha: 0.15),
              blurRadius: 18,
              offset:     const Offset(0, 6),
            )]
                : AppTheme.softShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: OnboardingConstants.genderCardDuration,
                style: TextStyle(fontSize: isSelected ? 52 : 42),
                child: Text(emoji),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize:   17,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppTheme.brandPrimary
                      : AppTheme.brandDark,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity:  isSelected ? 1.0 : 0.0,
                duration: OnboardingConstants.genderCardDuration,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color:        AppTheme.brandPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Selected ✓',
                    style: TextStyle(
                      fontFamily:  'Poppins',
                      fontSize:    10,
                      fontWeight:  FontWeight.w700,
                      color:       Colors.white,
                    ),
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

// ══════════════════════════════════════════════════════════════
// STEP 3 — Birthday picker
// ══════════════════════════════════════════════════════════════
class _Step3Birthday extends StatelessWidget {
  const _Step3Birthday({
    required this.dob,
    required this.touched,
    required this.firstName,
    required this.isFemale,
    required this.onChanged,
  });
  final DateTime dob;
  final bool     touched;
  final bool     isFemale;
  final String   firstName;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
        OnboardingConstants.stepHorizontalPad,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeAnimation(
            delayInMs: 0,
            child: _StepTitle(
              title: firstName.isNotEmpty
                  ? 'When is your\nbirthday, $firstName?'
                  : 'When is your\nbirthday?',
              subtitle: 'Your birth year will be kept private.',
            ),
          ),
          const SizedBox(height: 24),

          FadeAnimation(
            delayInMs: 100,
            child: Container(
              height: OnboardingConstants.pickerCardHeight,
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(
                    OnboardingConstants.pickerCardRadius),
                boxShadow:    AppTheme.heavyShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    OnboardingConstants.pickerCardRadius),
                child: CupertinoDatePicker(
                  mode:            CupertinoDatePickerMode.date,
                  initialDateTime: dob,
                  minimumDate:     DateTime(1950),
                  maximumDate:     DateTime(DateTime.now().year - 18),
                  onDateTimeChanged: (d) {
                    HapticUtils.selectionClick();
                    onChanged(d);
                  },
                ),
              ),
            ),
          ),

          const Spacer(),

          AnimatedOpacity(
            opacity:  touched ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 350),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  'Age: ${_calcAge(dob)} years',
                  style: const TextStyle(
                    fontFamily:  'Poppins',
                    fontSize:    14,
                    fontWeight:  FontWeight.w700,
                    color:       AppTheme.brandPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STEP 4 — Height pickers
// ══════════════════════════════════════════════════════════════
class _Step4Height extends StatelessWidget {
  const _Step4Height({
    required this.feet,
    required this.inches,
    required this.firstName,
    required this.isFemale,
    required this.onFeetChanged,
    required this.onInchesChanged,
  });
  final int    feet;
  final int    inches;
  final bool   isFemale;
  final String firstName;
  final ValueChanged<int> onFeetChanged;
  final ValueChanged<int> onInchesChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
        OnboardingConstants.stepHorizontalPad,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeAnimation(
            delayInMs: 0,
            child: _StepTitle(
              title: firstName.isNotEmpty
                  ? 'How tall are\nyou, $firstName?'
                  : 'How tall are\nyou?',
              subtitle: 'Helps find compatible matches.',
            ),
          ),
          const SizedBox(height: 24),

          FadeAnimation(
            delayInMs: 100,
            child: Container(
              height: OnboardingConstants.heightPickerCardHeight,
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(
                    OnboardingConstants.pickerCardRadius),
                boxShadow:    AppTheme.heavyShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: OnboardingConstants.pickerColumnWidth,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                          initialItem: feet - 4),
                      itemExtent: OnboardingConstants.pickerItemExtent,
                      onSelectedItemChanged: (i) {
                        HapticUtils.selectionClick();
                        onFeetChanged(i + 4);
                      },
                      children: List.generate(
                        4,
                            (i) => Center(
                          child: Text(
                            '${i + 4} ft',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize:   22,
                              fontWeight: FontWeight.w700,
                              color:      AppTheme.brandDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 26,
                      color:    Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(
                    width: OnboardingConstants.pickerColumnWidth,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                          initialItem: inches),
                      itemExtent: OnboardingConstants.pickerItemExtent,
                      onSelectedItemChanged: (i) {
                        HapticUtils.selectionClick();
                        onInchesChanged(i);
                      },
                      children: List.generate(
                        12,
                            (i) => Center(
                          child: Text(
                            '$i in',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize:   22,
                              fontWeight: FontWeight.w700,
                              color:      AppTheme.brandDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // ── FIX 7: fontSize 52 w900 → 44 w800 — less cramped ─
          FadeAnimation(
            delayInMs: 160,
            child: Center(
              child: Text(
                "$feet'$inches\"",
                style: const TextStyle(
                  fontFamily:    'Poppins',
                  fontSize:      44,      // was: 52
                  fontWeight:    FontWeight.w800, // was: w900
                  color:         AppTheme.brandPrimary,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STEP 5 — Community + Gotra
// ══════════════════════════════════════════════════════════════
class _Step5Community extends StatelessWidget {
  const _Step5Community({
    required this.gotra,
    required this.firstName,
    required this.onGotraChanged,
  });
  final String gotra;
  final String firstName;
  final ValueChanged<String> onGotraChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeAnimation(
            delayInMs: 0,
            child: _StepTitle(
              title: firstName.isNotEmpty
                  ? 'Your roots,\n$firstName.'
                  : 'Your roots.',
              subtitle: 'Ensures cultural compatibility.',
            ),
          ),
          const SizedBox(height: 26),

          // ── FIX 1: sentence case ─────────────────────────
          const FadeAnimation(
            delayInMs: 80,
            child: _FieldLabel('Community'), // was: 'COMMUNITY'
          ),
          const SizedBox(height: 10),
          FadeAnimation(
            delayInMs: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    OnboardingConstants.communityChipRadius),
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded,
                      color: AppTheme.success, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Banjara',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize:   15,
                      fontWeight: FontWeight.w700,
                      color:      AppTheme.brandDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          const FadeAnimation(
            delayInMs: 140,
            child: _FieldLabel('Select gotra'), // was: 'SELECT GOTRA'
          ),
          const SizedBox(height: 12),
          FadeAnimation(
            delayInMs: 160,
            child: Wrap(
              spacing: 10, runSpacing: 10,
              children: _gotraList.map((g) => CustomChip(
                label: g,
                isSelected: gotra == g,
                onTap: () {
                  HapticUtils.selectionClick();
                  onGotraChanged(g);
                },
              )).toList(),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// STEP 6 — Photo upload
// ══════════════════════════════════════════════════════════════
class _Step6Photo extends StatelessWidget {
  const _Step6Photo({
    required this.uploaded,
    required this.scanStep,
    required this.firstName,
    required this.isFemale,
    required this.onPhotoTap,
  });
  final bool   uploaded;
  final int    scanStep;
  final String firstName;
  final bool   isFemale;
  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
        OnboardingConstants.stepHorizontalPad,
        OnboardingConstants.stepTopPad,
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FadeAnimation(
            delayInMs: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StepTitle(
                title: firstName.isNotEmpty
                    ? 'Last step,\n$firstName!'
                    : 'One last step!',
                subtitle: 'Add a profile photo so others can see you.',
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── FIX 4 + 8: Material+InkWell on photo card ────
          // InkWell(onTap: null) = auto-disabled, no ripple when uploaded
          FadeAnimation(
            delayInMs: 100,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(
                  OnboardingConstants.photoCardRadius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                // ── FIX 8: null onTap when uploaded = no ripple ──
                onTap: uploaded ? null : onPhotoTap,
                borderRadius: BorderRadius.circular(
                    OnboardingConstants.photoCardRadius),
                splashColor: AppTheme.brandPrimary.withValues(alpha: 0.06),
                child: AnimatedContainer(
                  duration: OnboardingConstants.containerAnimDuration,
                  width:  OnboardingConstants.photoCardWidth,
                  height: OnboardingConstants.photoCardHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        OnboardingConstants.photoCardRadius),
                    border: Border.all(
                      color: scanStep == 2
                          ? AppTheme.success
                          : uploaded
                          ? Colors.grey.shade300
                          : AppTheme.brandPrimary.withValues(alpha: 0.30),
                      width: scanStep == 2 ? 2.5 : 1.5,
                    ),
                    boxShadow: scanStep == 2
                        ? [BoxShadow(
                      color:      AppTheme.success.withValues(alpha: 0.20),
                      blurRadius: 20,
                      offset:     const Offset(0, 8),
                    )]
                        : AppTheme.mediumShadow,
                    image: uploaded
                        ? DecorationImage(
                      image: NetworkImage(
                        isFemale
                            ? AppAssets.dummyFemalePhotos[0]
                            : AppAssets.dummyMalePhotos[0],
                      ),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        OnboardingConstants.photoCardRadius - 2),
                    child: !uploaded
                        ? const _UploadPlaceholder()
                        : scanStep == 1
                        ? const _ScanningOverlay()
                        : const _VerifiedBadge(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          FadeAnimation(
            delayInMs: 180,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _buildStatus(),
            ),
          ),
          const SizedBox(height: 28),

          FadeAnimation(
            delayInMs: 240,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(
                    OnboardingConstants.infoNoteRadius),
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size:  15,
                    color: AppTheme.brandPrimary.withValues(alpha: 0.65),
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'Your city and other details can be filled in after '
                          'signing up inside the app.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize:   11,
                        color:      AppTheme.textSecondary,
                        height:     1.55,
                      ),
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

  Widget _buildStatus() {
    if (scanStep == 2) {
      return const Row(
        key: ValueKey('verified'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 15, color: AppTheme.success),
          SizedBox(width: 6),
          Text(
            'Photo verified — looking great!',
            style: TextStyle(
              fontFamily:  'Poppins',
              fontSize:    12,
              fontWeight:  FontWeight.w600,
              color:       AppTheme.success,
            ),
          ),
        ],
      );
    }
    if (scanStep == 1) {
      return const Text(
        'Verifying your photo...',
        key: ValueKey('scanning'),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   12,
          color:      AppTheme.textSecondary,
        ),
      );
    }
    return const Text(
      'Tap the card above to upload your photo',
      key: ValueKey('idle'),
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize:   12,
        color:      AppTheme.textSecondary,
      ),
    );
  }
}

// ── Upload placeholder ────────────────────────────────────────
class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color:  AppTheme.brandPrimary.withValues(alpha: 0.08),
            shape:  BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            color: AppTheme.brandPrimary,
            size:  28,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Upload Photo',
          style: TextStyle(
            fontFamily:  'Poppins',
            fontSize:    13,
            fontWeight:  FontWeight.w700,
            color:       AppTheme.brandDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to choose',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize:   11,
            color:      Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

// ── Scanning overlay ──────────────────────────────────────────
class _ScanningOverlay extends StatelessWidget {
  const _ScanningOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.48),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color:       AppTheme.brandPrimary,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 14),
          Text(
            'Verifying...',
            style: TextStyle(
              fontFamily:  'Poppins',
              fontSize:    13,
              color:       Colors.white,
              fontWeight:  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Verified badge ────────────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 12, left: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color:        AppTheme.success,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color:      AppTheme.success.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_rounded,
                    color: Colors.white, size: 13),
                SizedBox(width: 5),
                Text(
                  'Verified ✓',
                  style: TextStyle(
                    fontFamily:  'Poppins',
                    fontSize:    11,
                    fontWeight:  FontWeight.w700,
                    color:       Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CELEBRATION OVERLAY
// ══════════════════════════════════════════════════════════════
class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({required this.firstName});
  final String firstName;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with TickerProviderStateMixin {

  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _confettiCtrl;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  late final List<_Particle> _particles;

  static const _colors = [
    Color(0xFFE8395A), Color(0xFFF5C842), Color(0xFF16A34A),
    Color(0xFF7C3AED), Color(0xFF2563EB), Color(0xFFFF6B84),
  ];

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _particles = List.generate(55, (_) => _Particle(
      x:        rng.nextDouble(),
      delay:    rng.nextDouble() * 0.5,
      color:    _colors[rng.nextInt(_colors.length)],
      size:     5 + rng.nextDouble() * 7,
      rotation: rng.nextDouble() * 2 * math.pi,
      isCircle: rng.nextBool(),
    ));

    _fadeCtrl     = AnimationController(
        vsync: this,
        duration: OnboardingConstants.celebrationFadeDuration);
    _scaleCtrl    = AnimationController(
        vsync: this,
        duration: OnboardingConstants.celebrationScaleDuration);
    _confettiCtrl = AnimationController(
        vsync: this,
        duration: OnboardingConstants.confettiDuration);

    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack));

    _fadeCtrl.forward();
    _scaleCtrl.forward();
    _confettiCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: Colors.black.withValues(alpha: 0.60),
        child: Stack(
          children: [
            // ── FIX 3: builder: (_, _) → (_, __) — compile fix ──
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress:  _confettiCtrl.value,
                ),
              ),
            ),

            Center(
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  margin:  const EdgeInsets.symmetric(horizontal: 36),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(
                        AuthConstants.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.20),
                        blurRadius: 36,
                        offset:     const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: const BoxDecoration(
                          shape:    BoxShape.circle,
                          gradient: AppTheme.goldGradient,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size:  34,
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        widget.firstName.isNotEmpty
                            ? 'Welcome, ${widget.firstName}! 🎉'
                            : 'Welcome! 🎉',
                        textAlign: TextAlign.center, // FIX: center for long names
                        style: const TextStyle(
                          fontFamily:  'Cormorant Garamond',
                          fontSize:    22, // FIX: was 26 — emoji wrap fix
                          fontWeight:  FontWeight.w700,
                          color:       AppTheme.brandDark,
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        'Your profile is ready.\nStep into the VIP Lounge.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize:   13,
                          color:      AppTheme.textSecondary,
                          height:     1.5,
                        ),
                      ),
                      const SizedBox(height: 18),

                      const LinearProgressIndicator(
                        backgroundColor: Color(0xFFF0F0F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.brandPrimary),
                        minHeight:    3,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confetti particle model ───────────────────────────────────
class _Particle {
  const _Particle({
    required this.x,
    required this.delay,
    required this.color,
    required this.size,
    required this.rotation,
    required this.isCircle,
  });
  final double x, delay, size, rotation;
  final Color  color;
  final bool   isCircle;
}

// ── Confetti painter ──────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.particles,
    required this.progress,
  });
  final List<_Particle> particles;
  final double          progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final opacity = t < 0.75 ? 1.0 : (1.0 - t) / 0.25;
      final paint   = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(p.x * size.width, t * size.height * 1.1);
      canvas.rotate(p.rotation + t * 3.5);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width:  p.size,
            height: p.size * 0.45,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}