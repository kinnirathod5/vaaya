import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// 🚀 GoRouter import kiya hai taaki makkhan ki tarah navigation ho sake
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final Color _brandPrimary = const Color(0xFFF23B5F);
  final Color _brandDark = const Color(0xFF2A2D34);
  final Color _bgScaffold = const Color(0xFFF4F7FC);

  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();

  bool _isPhoneValid = false;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "https://images.unsplash.com/photo-1583089892943-e02e52f17d50?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80",
      "title": "Find Your\nPerfect Match",
      "subtitle": "Join the most exclusive and trusted Banjara community."
    },
    {
      "image": "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80",
      "title": "100% Secure\n& Private",
      "subtitle": "Your data is encrypted, verified, and completely safe with us."
    },
    {
      "image": "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80",
      "title": "Premium\nExperience",
      "subtitle": "Get 10x more matches with our smart matchmaking AI."
    },
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      if (_currentPage < _onboardingData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    _phoneFocus.addListener(() => setState(() {}));

    _phoneController.addListener(() {
      final text = _phoneController.text;
      if (text.length == 10 && !_isPhoneValid) {
        HapticFeedback.heavyImpact();
        setState(() => _isPhoneValid = true);
      } else if (text.length < 10 && _isPhoneValid) {
        setState(() => _isPhoneValid = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _phoneFocus.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // ==========================================
            // 1. TOP HALF: CAROUSEL
            // ==========================================
            Positioned(
              top: 0, left: 0, right: 0,
              height: screenHeight * 0.58,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) => setState(() => _currentPage = page),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: _currentPage == index ? 1.0 : 1.15, end: _currentPage == index ? 1.15 : 1.0),
                            duration: const Duration(seconds: 7),
                            curve: Curves.linear,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Image.network(_onboardingData[index]["image"]!, fit: BoxFit.cover),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.8)],
                                stops: const [0.4, 0.7, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 50, left: 30, right: 30,
                            child: Column(
                              children: [
                                Text(
                                  _onboardingData[index]["title"]!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _onboardingData[index]["subtitle"]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    bottom: 30, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6, width: _currentPage == index ? 24 : 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? _brandPrimary : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. BOTTOM HALF: SMART LOGIN PANEL
            // ==========================================
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              bottom: bottomInset,
              left: 0, right: 0,
              height: screenHeight * 0.45,
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 25),
                decoration: BoxDecoration(
                  color: _bgScaffold,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                      const SizedBox(height: 25),

                      // 📞 Input Field (Double border fixed 🔥)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          // 🔥 Outer Premium Border
                          border: Border.all(
                              color: _phoneFocus.hasFocus ? _brandPrimary : Colors.grey.shade300,
                              width: _phoneFocus.hasFocus ? 2.0 : 1.0
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: _phoneFocus.hasFocus ? _brandPrimary.withOpacity(0.1) : Colors.black.withOpacity(0.02),
                                blurRadius: 15,
                                offset: const Offset(0, 5)
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text('+91', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: _brandDark)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly],
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: _brandDark, fontWeight: FontWeight.bold, letterSpacing: 2),
                                cursorColor: _brandPrimary,
                                decoration: InputDecoration(
                                  // 🔥 FIX: Saare internal borders ko forcefully 'none' kar diya
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: 'Mobile Number',
                                    hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade400, letterSpacing: 0, fontWeight: FontWeight.normal)
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: _isPhoneValid ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Icon(Icons.check_circle_rounded, color: Colors.green.shade400, size: 20)
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 🔘 Action Button
                      GestureDetector(
                        onTap: () {
                          if (_isPhoneValid) {
                            HapticFeedback.heavyImpact();
                            FocusScope.of(context).unfocus();
                            context.push('/otp');
                          } else {
                            HapticFeedback.vibrate();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, width: double.infinity, height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18), color: _isPhoneValid ? _brandPrimary : Colors.grey.shade200,
                            boxShadow: _isPhoneValid ? [BoxShadow(color: _brandPrimary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))] : [],
                          ),
                          child: Center(
                              child: Text(
                                  _isPhoneValid ? 'Get OTP' : 'Enter Number',
                                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: _isPhoneValid ? Colors.white : Colors.grey.shade400, letterSpacing: 1)
                              )
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ➖ Divider & Guest
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text('OR', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600))),
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🕵️ Guest Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          context.go('/dashboard');
                        },
                        child: Container(
                          width: double.infinity, height: 55,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.explore_rounded, color: Colors.grey.shade600, size: 20),
                              const SizedBox(width: 10),
                              Text('Explore App as Guest', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('By continuing, you agree to our Terms & Privacy Policy.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.grey.shade400)),
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