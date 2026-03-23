import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';

// ============================================================
// 🎛️ SEARCH FILTER BOTTOM SHEET
// Advanced filters: age, height, city, education, toggles
// TODO: filterProvider se connect karo (Riverpod)
// ============================================================
class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({super.key});

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState
    extends State<SearchFilterBottomSheet> {

  RangeValues _ageRange    = const RangeValues(21, 32);
  RangeValues _heightRange = const RangeValues(150, 175);
  String _city             = 'Any';
  String _education        = 'Any';
  bool _onlineOnly         = false;
  bool _premiumOnly        = false;

  static const List<String> _cities = [
    'Any', 'Mumbai', 'Pune', 'Nagpur', 'Nashik',
    'Aurangabad', 'Kolhapur', 'Delhi', 'Bangalore',
  ];

  static const List<String> _educations = [
    'Any', 'B.Tech', 'MBBS', 'CA', 'B.Arch',
    'LLB', 'MBA', 'M.Tech', 'B.Des', 'M.Ed',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Matches',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    letterSpacing: -0.3,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppTheme.brandPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Age range
                  _SectionLabel('Age Range'),
                  _RangeHint(
                    '${_ageRange.start.round()} – ${_ageRange.end.round()} years',
                  ),
                  RangeSlider(
                    values: _ageRange,
                    min: 18, max: 50, divisions: 32,
                    activeColor: AppTheme.brandPrimary,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (v) {
                      HapticUtils.selectionClick();
                      setState(() => _ageRange = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Height range
                  _SectionLabel('Height Range'),
                  _RangeHint(
                    '${_cmToFeet(_heightRange.start.round())} – ${_cmToFeet(_heightRange.end.round())}',
                  ),
                  RangeSlider(
                    values: _heightRange,
                    min: 140, max: 190, divisions: 50,
                    activeColor: AppTheme.brandPrimary,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (v) {
                      HapticUtils.selectionClick();
                      setState(() => _heightRange = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // City
                  _SectionLabel('City'),
                  const SizedBox(height: 10),
                  _ChipGroup(
                    items: _cities,
                    selected: _city,
                    onSelect: (v) => setState(() => _city = v),
                  ),
                  const SizedBox(height: 16),

                  // Education
                  _SectionLabel('Education'),
                  const SizedBox(height: 10),
                  _ChipGroup(
                    items: _educations,
                    selected: _education,
                    onSelect: (v) => setState(() => _education = v),
                  ),
                  const SizedBox(height: 16),

                  // Preference toggles
                  _SectionLabel('Preferences'),
                  const SizedBox(height: 10),
                  _ToggleRow(
                    label: 'Online users only',
                    subtitle: 'Show only currently active profiles',
                    value: _onlineOnly,
                    onChanged: (v) => setState(() => _onlineOnly = v),
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    label: 'Premium profiles only',
                    subtitle: 'Verified and premium members',
                    value: _premiumOnly,
                    onChanged: (v) => setState(() => _premiumOnly = v),
                  ),
                  const SizedBox(height: 28),

                  // Apply
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
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

  String _cmToFeet(int cm) {
    final inches = (cm / 2.54).round();
    return "${inches ~/ 12}'${inches % 12}\"";
  }

  void _reset() {
    HapticUtils.lightImpact();
    setState(() {
      _ageRange    = const RangeValues(21, 32);
      _heightRange = const RangeValues(150, 175);
      _city        = 'Any';
      _education   = 'Any';
      _onlineOnly  = false;
      _premiumOnly = false;
    });
  }

  void _apply() {
    HapticUtils.mediumImpact();
    // TODO: filterProvider.applyFilters({...})
    Navigator.of(context).pop();
  }
}


// ── Private section widgets ───────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: AppTheme.brandDark,
    ),
  );
}

class _RangeHint extends StatelessWidget {
  const _RangeHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      color: Colors.grey.shade500,
    ),
  );
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selected;
        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            onSelect(item);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.brandPrimary
                    : Colors.grey.shade200,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                )),
                const SizedBox(height: 1),
                Text(subtitle, style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.grey.shade500,
                )),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.88,
            child: Switch(
              value: value,
              onChanged: (v) {
                HapticUtils.selectionClick();
                onChanged(v);
              },
              activeColor: AppTheme.brandPrimary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}