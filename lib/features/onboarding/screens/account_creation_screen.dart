import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare banaye hue saare Premium Tools (Lego Blocks)
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/custom_chip.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  // --- USER DATA VARIABLES ---
  String _profileCreatedFor = '';
  final List<String> _createdForOptions = ['Self', 'Son', 'Daughter', 'Brother', 'Sister', 'Relative'];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  DateTime _selectedDate = DateTime(2000, 1, 1);
  bool _isDateInteracted = false;

  int _heightFeet = 5;
  int _heightInches = 5;

  String _selectedGotra = '';
  final List<String> _gotraList = ['Rathod', 'Chavan', 'Pawar', 'Jadhav', 'Ade', 'Naik', 'Muqayya', 'Gormati'];

  // 🔥 Naya Step 5 variables
  String _selectedGender = '';
  final TextEditingController _locationController = TextEditingController();

  bool _hasUploadedPhoto = false;
  int _scanStep = 0;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _locationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // 🔥 THE SMART VALIDATION ENGINE
  bool _canGoNext() {
    switch (_currentStep) {
      case 0: // Profile Created For & Name
        return _profileCreatedFor.isNotEmpty &&
            _firstNameController.text.trim().length >= 2 &&
            _lastNameController.text.trim().length >= 2;
      case 1: // DOB
        return _isDateInteracted;
      case 2: // Height
        return true;
      case 3: // Gotra
        return _selectedGotra.isNotEmpty;
      case 4: // Gender & Location
        return _selectedGender.isNotEmpty &&
            _locationController.text.trim().length >= 3;
      case 5: // Photo
        return _hasUploadedPhoto && _scanStep == 2;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canGoNext()) {
      FocusScope.of(context).unfocus();

      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
      } else {
        // FINAL STEP: VIP Lounge (Dashboard) par bhejein!
        HapticUtils.heavyImpact();
        context.go('/dashboard');
      }
    } else {
      HapticUtils.errorVibrate();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      HapticUtils.lightImpact();
      FocusScope.of(context).unfocus();
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
    } else {
      context.pop(); // Pehle step se bhi back jane par
    }
  }

  // --- 📸 PHOTO UPLOAD SIMULATION ---
  void _startPhotoScan() {
    setState(() {
      _hasUploadedPhoto = true;
      _scanStep = 1; // Scanning State
    });

    // Simulate AI Scanning Delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _scanStep = 2); // Verified State
        CustomToast.showSuccess(context, 'AI Face Verification Successful!');
      }
    });
  }

  String _getFirstName() {
    String name = _firstNameController.text.trim();
    return name.isEmpty ? '' : name.split(' ').first;
  }

  // 🛡️ Trust Tooltip
  Widget _buildTrustTooltip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
        ],
      ),
    );
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
            // ✨ THE DYNAMIC AMBIENT GLOW
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic,
              top: _currentStep % 2 == 1 ? 200 : -50,
              left: _currentStep % 2 == 0 ? -50 : null,
              right: _currentStep % 2 == 1 ? -50 : null,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.brandPrimary.withOpacity(0.12))),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutCubic,
              bottom: _currentStep % 2 == 0 ? 100 : -100,
              right: _currentStep % 2 == 0 ? -50 : null,
              left: _currentStep % 2 == 1 ? -50 : null,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.08))),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // --- TOP NAVIGATION BAR & PROGRESS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _prevStep,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200), boxShadow: AppTheme.softShadow),
                                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.brandDark, size: 18),
                              ),
                            ),
                            Text('Step ${_currentStep + 1} of $_totalSteps', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                            const SizedBox(width: 45), // Balancing space for back button
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_totalSteps, (index) {
                            bool isCompleted = index <= _currentStep;
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isCompleted ? AppTheme.brandPrimary : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isCompleted ? [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))] : [],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // --- MAIN CONTENT AREA (PAGES) ---
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1Basics(),        // 1. Created For, First Name, Last Name
                        _buildStep2Birthday(),      // 2. DOB
                        _buildStep3Height(),        // 3. Height
                        _buildStep4Community(),     // 4. Gotra
                        _buildStep5GenderLocation(),// 5. Gender & Location
                        _buildStep6Photo(),         // 6. Photo Upload
                      ],
                    ),
                  ),

                  // --- 🔘 BOTTOM BUTTON (Humara Reusable Lego Block) ---
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, MediaQuery.of(context).viewInsets.bottom > 0 ? 15 : 30),
                    child: PrimaryButton(
                      text: _currentStep == _totalSteps - 1 ? 'Enter VIP Lounge' : 'Continue',
                      isEnabled: _canGoNext(),
                      onTap: _nextStep,
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

  // =========================================================================
  // 📝 STEP 1: Profile Created For, First & Last Name
  // =========================================================================
  Widget _buildStep1Basics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Let\'s start with\nthe basics.', style: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.brandDark, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 10),
          Text('Please provide genuine details to build trust.', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 35),

          Text('PROFILE CREATED FOR', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _createdForOptions.map((option) {
              return CustomChip(
                label: option,
                isSelected: _profileCreatedFor == option,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _profileCreatedFor = option);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          Text('FIRST NAME', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          CustomTextField(
            hintText: 'e.g. Rahul',
            controller: _firstNameController,
          ),
          const SizedBox(height: 20),

          Text('LAST NAME', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          CustomTextField(
            hintText: 'e.g. Rathod',
            controller: _lastNameController,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // =========================================================================
  // 🎂 STEP 2: Birthday
  // =========================================================================
  Widget _buildStep2Birthday() {
    String firstName = _getFirstName();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(firstName.isNotEmpty ? 'When is your\nbirthday, $firstName?' : 'When is your\nbirthday?', style: const TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.brandDark, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 10),
          _buildTrustTooltip('Your exact year is hidden', Icons.lock_outline_rounded),
          const SizedBox(height: 40),

          Center(
            child: Container(
              height: 220,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.heavyShadow),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: DateTime(1950),
                maximumDate: DateTime(DateTime.now().year - 18),
                onDateTimeChanged: (DateTime newDate) {
                  HapticUtils.selectionClick();
                  setState(() {
                    _selectedDate = newDate;
                    _isDateInteracted = true;
                  });
                },
              ),
            ),
          ),
          const Spacer(),
          if (_isDateInteracted)
            Center(
              child: AnimatedOpacity(
                opacity: 1.0, duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppTheme.brandPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('Age: ${DateTime.now().year - _selectedDate.year} years', style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.brandPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =========================================================================
  // 📏 STEP 3: Height
  // =========================================================================
  Widget _buildStep3Height() {
    String firstName = _getFirstName();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(firstName.isNotEmpty ? 'How tall\nare you, $firstName?' : 'How tall\nare you?', style: const TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.brandDark, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 10),
          _buildTrustTooltip('Helps find the perfect match', Icons.favorite_border_rounded),
          const SizedBox(height: 40),

          Container(
            height: 250,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.heavyShadow),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: _heightFeet - 4),
                    itemExtent: 50,
                    onSelectedItemChanged: (int index) {
                      HapticUtils.selectionClick();
                      setState(() => _heightFeet = index + 4);
                    },
                    children: List.generate(4, (index) => Center(child: Text('${index + 4} ft', style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.brandDark)))),
                  ),
                ),
                Text(':', style: TextStyle(fontSize: 30, color: Colors.grey.shade300)),
                SizedBox(
                  width: 100,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: _heightInches),
                    itemExtent: 50,
                    onSelectedItemChanged: (int index) {
                      HapticUtils.selectionClick();
                      setState(() => _heightInches = index);
                    },
                    children: List.generate(12, (index) => Center(child: Text('$index in', style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.brandDark)))),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(child: Text("$_heightFeet'$_heightInches\"", style: const TextStyle(fontFamily: 'Poppins', fontSize: 45, fontWeight: FontWeight.w900, color: AppTheme.brandPrimary))),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =========================================================================
  // 🤝 STEP 4: Community & Gotra
  // =========================================================================
  Widget _buildStep4Community() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Your roots\nmatter.', style: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.brandDark, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 10),
          _buildTrustTooltip('Ensures cultural compatibility', Icons.diversity_1_rounded),
          const SizedBox(height: 40),

          Text('COMMUNITY', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.brandPrimary.withOpacity(0.5))),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Colors.green, size: 22),
                SizedBox(width: 10),
                Text('Banjara', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
              ],
            ),
          ),
          const SizedBox(height: 35),

          Text('SELECT GOTRA (SURNAME)', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12, runSpacing: 15,
            children: _gotraList.map((gotra) {
              return CustomChip(
                label: gotra,
                isSelected: _selectedGotra == gotra,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _selectedGotra = gotra);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 📍 STEP 5: Gender & Location
  // =========================================================================
  Widget _buildStep5GenderLocation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('A bit more\nabout you.', style: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.brandDark, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 10),
          _buildTrustTooltip('Helps us find matches near you', Icons.location_on_outlined),
          const SizedBox(height: 35),

          Text('I AM A', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildGenderCard('Male', Icons.male_rounded)),
              const SizedBox(width: 15),
              Expanded(child: _buildGenderCard('Female', Icons.female_rounded)),
            ],
          ),
          const SizedBox(height: 35),

          Text('CURRENT LOCATION (CITY)', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          CustomTextField(
            hintText: 'e.g. Mumbai, Maharashtra',
            controller: _locationController,
            prefixIcon: Icons.location_city_rounded,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String title, IconData icon) {
    bool isSelected = _selectedGender == title;
    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() => _selectedGender = title);
        FocusScope.of(context).unfocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), height: 100,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandPrimary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade200, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? AppTheme.primaryGlow : AppTheme.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.brandDark : Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 📸 STEP 6: AI Photo Scanner (Last Step)
  // =========================================================================
  Widget _buildStep6Photo() {
    String firstName = _getFirstName();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(firstName.isNotEmpty ? 'Put a face to\nthe name, $firstName.' : 'Put a face to\nthe name.', style: const TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.brandDark, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 10),
          _buildTrustTooltip('AI strictly blocks fake photos', Icons.security_rounded),
          const SizedBox(height: 40),

          Center(
            child: GestureDetector(
              onTap: _hasUploadedPhoto ? null : _startPhotoScan,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 220, height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _scanStep == 2 ? Colors.green.shade400 : Colors.grey.shade300, width: 2),
                  boxShadow: AppTheme.heavyShadow,
                  image: _hasUploadedPhoto
                      ? const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'), fit: BoxFit.cover)
                      : null,
                ),
                child: !_hasUploadedPhoto
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.brandPrimary.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.add_a_photo_rounded, color: AppTheme.brandPrimary, size: 30)),
                    const SizedBox(height: 15),
                    const Text('Tap to Upload', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                  ],
                )
                    : Stack(
                  children: [
                    if (_scanStep == 1)
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(28)),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppTheme.brandPrimary),
                              SizedBox(height: 15),
                              Text('AI Scanning Face...', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    if (_scanStep == 2)
                      Positioned(
                        bottom: 15, left: 0, right: 0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(color: Colors.green.shade500, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10)]),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 5),
                              Text('Face Verified!', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}