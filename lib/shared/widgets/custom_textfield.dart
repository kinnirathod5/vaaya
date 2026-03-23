import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

// ============================================================
// 📝 CUSTOM TEXT FIELD
// Premium form input used across all screens.
// Supports: prefix icon, suffix, validation, focus animation,
//           character limit, input formatters, multiline.
//
// Usage:
//   CustomTextField(hintText: 'First name', controller: _ctrl)
//
//   CustomTextField(
//     hintText: 'City',
//     controller: _ctrl,
//     prefixIcon: Icons.location_city_rounded,
//   )
//
//   CustomTextField(
//     hintText: 'Bio',
//     controller: _ctrl,
//     maxLines: 4,
//     maxLength: 300,
//   )
// ============================================================
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.showClearButton = false,
  });

  /// Placeholder text shown when field is empty
  final String hintText;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Leading icon inside the field
  final IconData? prefixIcon;

  /// Custom trailing widget (e.g. password toggle, dropdown arrow)
  final Widget? suffixIcon;

  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Return error string to show below field, null if valid
  final String? Function(String?)? validator;

  final List<TextInputFormatter>? inputFormatters;

  /// Number of lines — use > 1 for multiline (e.g. bio field)
  final int maxLines;

  /// Character limit — shows counter when set
  final int? maxLength;

  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  /// Show × clear button when field has text
  final bool showClearButton;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {

  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  bool _isFocused = false;
  String? _errorText;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();

    _focusNode.addListener(() {
      final focused = _focusNode.hasFocus;
      if (focused != _isFocused) {
        setState(() => _isFocused = focused);
        // Validate on blur
        if (!focused && widget.validator != null) {
          setState(() => _errorText = widget.validator!(_controller.text));
        }
      }
    });

    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
      // Clear error when typing
      if (_errorText != null) setState(() => _errorText = null);
    });
  }

  @override
  void dispose() {
    // Only dispose if we created them internally
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (_errorText != null) return AppTheme.error;
    if (_isFocused) return AppTheme.brandPrimary;
    if (_hasText) return AppTheme.brandPrimary.withValues(alpha: 0.25);
    return Colors.grey.shade200;
  }

  double get _borderWidth {
    if (_isFocused || _errorText != null) return 2;
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        // ── Input field ───────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: _borderWidth,
            ),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : AppTheme.softShadow,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.enabled
                  ? AppTheme.brandDark
                  : Colors.grey.shade400,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 4 : 16,
                vertical: widget.maxLines > 1 ? 14 : 16,
              ),
              counterText: '', // Hide default counter
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 4),
                child: Icon(
                  widget.prefixIcon,
                  size: 18,
                  color: _isFocused
                      ? AppTheme.brandPrimary
                      : Colors.grey.shade400,
                ),
              )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44, minHeight: 44,
              ),
              suffixIcon: _buildSuffix(),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 44, minHeight: 44,
              ),
            ),
          ),
        ),

        // ── Error text ────────────────────────────────
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 13,
                  color: AppTheme.error,
                ),
                const SizedBox(width: 5),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ),

        // ── Character counter ─────────────────────────
        if (widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  final count = _controller.text.length;
                  final limit = widget.maxLength!;
                  final isNearLimit = count >= (limit * 0.85).round();
                  return Text(
                    '$count / $limit',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isNearLimit
                          ? AppTheme.warning
                          : Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  // ── Suffix widget ─────────────────────────────────────────
  Widget? _buildSuffix() {
    // Custom suffix takes priority
    if (widget.suffixIcon != null) return widget.suffixIcon;

    // Clear button
    if (widget.showClearButton && _hasText) {
      return GestureDetector(
        onTap: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.cancel_rounded,
            size: 18,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return null;
  }
}