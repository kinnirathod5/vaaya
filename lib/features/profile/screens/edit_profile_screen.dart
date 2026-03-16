import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/custom_toast.dart';
import '../../../shared/animations/fade_animation.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../shared/widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 🌟 Form Controllers (Dummy data se pre-fill kiya hai)
  final TextEditingController _nameController = TextEditingController(text: 'Rahul Rathod');
  final TextEditingController _ageController = TextEditingController(text: '28');
  final TextEditingController _heightController = TextEditingController(text: "5'10\"");
  final TextEditingController _gotraController = TextEditingController(text: 'Rathod');
  final TextEditingController _professionController = TextEditingController(text: 'Senior Software Engineer');
  final TextEditingController _companyController = TextEditingController(text: 'Google India');
  final TextEditingController _aboutController = TextEditingController(text: 'Simple, ambitious, and family-oriented. Love traveling and exploring new cafes.');

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _gotraController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    HapticUtils.heavyImpact();
    // TODO: Backend me data save karne ka logic yahan aayega

    CustomToast.showSuccess(context, 'Profile Updated Successfully!');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) context.pop(); // Wapas My Profile par le jayega
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Keyboard hide karne ke liye
      child: Scaffold(
        backgroundColor: AppTheme.bgScaffold,
        appBar: AppBar(
          backgroundColor: AppTheme.bgScaffold,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.brandDark, size: 20),
            onPressed: () {
              HapticUtils.lightImpact();
              context.pop();
            },
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.brandDark),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📸 1. PHOTO EDITOR
              FadeAnimation(
                delayInMs: 100,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: const CustomNetworkImage(
                          imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
                          width: 120,
                          height: 120,
                          borderRadius: 60,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            HapticUtils.mediumImpact();
                            // Image Picker Logic
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.brandPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 👤 2. BASIC DETAILS
              _buildSectionTitle('Basic Details'),
              FadeAnimation(delayInMs: 200, child: _buildInputField('Full Name', Icons.person_outline_rounded, _nameController)),
              FadeAnimation(
                delayInMs: 250,
                child: Row(
                  children: [
                    Expanded(child: _buildInputField('Age', Icons.cake_outlined, _ageController, isNumber: true)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildInputField('Height', Icons.height_rounded, _heightController)),
                  ],
                ),
              ),
              FadeAnimation(delayInMs: 300, child: _buildInputField('Gotra', Icons.family_restroom_outlined, _gotraController)),
              const SizedBox(height: 30),

              // 💼 3. CAREER & EDUCATION
              _buildSectionTitle('Career & Education'),
              FadeAnimation(delayInMs: 350, child: _buildInputField('Profession', Icons.work_outline_rounded, _professionController)),
              FadeAnimation(delayInMs: 400, child: _buildInputField('Company / Business', Icons.business_rounded, _companyController)),
              const SizedBox(height: 30),

              // 📝 4. ABOUT ME
              _buildSectionTitle('About Me'),
              FadeAnimation(
                delayInMs: 450,
                child: _buildInputField(
                  'Write a few words about yourself...',
                  Icons.edit_note_rounded,
                  _aboutController,
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 40),

              // 💾 5. SAVE BUTTON
              FadeAnimation(
                delayInMs: 500,
                child: PrimaryButton(
                  text: 'Save Changes',
                  onTap: _saveProfile,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 📝 Helper: Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.brandDark
        ),
      ),
    );
  }

  // ⌨️ Helper: Premium Input Field
  Widget _buildInputField(String hint, IconData icon, TextEditingController controller, {int maxLines = 1, bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppTheme.brandDark, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade400),
          prefixIcon: maxLines == 1
              ? Icon(icon, color: Colors.grey.shade400, size: 20)
              : Padding(
            padding: const EdgeInsets.only(bottom: 60), // Align icon to top for multiline
            child: Icon(icon, color: Colors.grey.shade400, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}