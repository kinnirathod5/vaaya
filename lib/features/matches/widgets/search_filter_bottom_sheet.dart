import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/primary_button.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({super.key});

  @override
  State<SearchFilterBottomSheet> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  // 🌟 Filter States (Dummy Default Values)
  RangeValues _ageRange = const RangeValues(22, 35);
  RangeValues _heightRange = const RangeValues(152, 182); // in cm (approx 5'0" to 6'0")

  String _selectedMaritalStatus = 'Never Married';
  final List<String> _maritalStatusOptions = ['Never Married', 'Awaiting Divorce', 'Divorced', 'Widowed'];

  String _selectedDiet = 'Doesn\'t Matter';
  final List<String> _dietOptions = ['Doesn\'t Matter', 'Vegetarian', 'Non-Vegetarian', 'Vegan'];

  // Height conversion helper (cm to feet/inches string)
  String _cmToFeet(double cm) {
    int inches = (cm / 2.54).round();
    int feet = inches ~/ 12;
    int remainingInches = inches % 12;
    return "$feet'$remainingInches\"";
  }

  void _applyFilters() {
    HapticUtils.heavyImpact();
    // TODO: Pass filter data back or trigger search logic
    context.pop(); // Close bottom sheet
  }

  void _resetFilters() {
    HapticUtils.lightImpact();
    setState(() {
      _ageRange = const RangeValues(18, 40);
      _heightRange = const RangeValues(140, 198);
      _selectedMaritalStatus = 'Never Married';
      _selectedDiet = 'Doesn\'t Matter';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Total screen height ka 90% lega (Full screen feel ke liye)
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // 🔘 Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // 🎩 Header Row (Reset | Title | Close)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _resetFilters,
                  child: const Text('Reset', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                const Text('Filters', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    context.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, size: 20, color: AppTheme.brandDark),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade200, height: 1),

          // 📜 Scrollable Filter Options
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎂 1. AGE RANGE
                  _buildSectionHeader('Age Range', '${_ageRange.start.toInt()} yrs - ${_ageRange.end.toInt()} yrs'),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 60,
                    divisions: 42,
                    activeColor: AppTheme.brandPrimary,
                    inactiveColor: AppTheme.brandPrimary.withOpacity(0.2),
                    onChanged: (RangeValues values) {
                      setState(() => _ageRange = values);
                      HapticUtils.selectionClick();
                    },
                  ),
                  const SizedBox(height: 30),

                  // 📏 2. HEIGHT RANGE
                  _buildSectionHeader('Height', '${_cmToFeet(_heightRange.start)} - ${_cmToFeet(_heightRange.end)}'),
                  const SizedBox(height: 10),
                  RangeSlider(
                    values: _heightRange,
                    min: 140, // ~4'7"
                    max: 200, // ~6'7"
                    activeColor: AppTheme.brandPrimary,
                    inactiveColor: AppTheme.brandPrimary.withOpacity(0.2),
                    onChanged: (RangeValues values) {
                      setState(() => _heightRange = values);
                      HapticUtils.selectionClick();
                    },
                  ),
                  const SizedBox(height: 30),

                  // 💍 3. MARITAL STATUS
                  _buildSectionHeader('Marital Status', ''),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _maritalStatusOptions.map((status) => _buildChoiceChip(
                      label: status,
                      isSelected: _selectedMaritalStatus == status,
                      onTap: () {
                        HapticUtils.lightImpact();
                        setState(() => _selectedMaritalStatus = status);
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 30),

                  // 🥗 4. DIET PREFERENCES
                  _buildSectionHeader('Diet Preferences', ''),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _dietOptions.map((diet) => _buildChoiceChip(
                      label: diet,
                      isSelected: _selectedDiet == diet,
                      onTap: () {
                        HapticUtils.lightImpact();
                        setState(() => _selectedDiet = diet);
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 30),

                  // 📍 5. LOCATION (Dummy Dropdown style)
                  _buildSectionHeader('Location / City', ''),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Anywhere in India', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppTheme.brandDark, fontWeight: FontWeight.w500)),
                        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 💼 6. PROFESSION (Dummy Dropdown style)
                  _buildSectionHeader('Profession', ''),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('All Professions', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppTheme.brandDark, fontWeight: FontWeight.w500)),
                        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50), // Bottom padding for smooth scrolling
                ],
              ),
            ),
          ),

          // 💾 Sticky Apply Button at Bottom
          Container(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: PrimaryButton(
              text: 'Show 124 Matches', // Dynamic number can be shown here later
              onTap: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }

  // 📝 Helper: Section Title with Dynamic Value
  Widget _buildSectionHeader(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
        if (value.isNotEmpty)
          Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.brandPrimary)),
      ],
    );
  }

  // 🏷️ Helper: Custom Choice Chip
  Widget _buildChoiceChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}