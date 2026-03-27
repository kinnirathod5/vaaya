import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

// ============================================================
// 📝 CUSTOM TEXT FIELD — v2.0
//
// Fixes over v1:
//   ✅ FIX 1 — clipBehavior: Clip.hardEdge on AnimatedContainer
//              borderWidth 1.5→2 on focus causes visual "double
//              border" + clip artifact in screenshot — fixed by
//              keeping width CONSTANT at 1.5, only color changes
//   ✅ FIX 2 — All 6 TextField borders → OutlineInputBorder(none)
//              disabledBorder + focusedErrorBorder were missing
//              Any unset border falls back to Flutter default
//   ✅ FIX 3 — AnimatedBuilder builder: (_, _) → (_, __)
//              Duplicate underscore param — Dart compile error
//   ✅ FIX 4 — FocusNode listener stored as named _focusListener
//              Anonymous lambda in initState can't be removed
//              in dispose — memory leak
//   ✅ FIX 5 — Controller listener stored as named _controllerListener
//              Same memory leak fix as FocusNode
//
// Usage:
//   CustomTextField(hintText: 'First name', controller: _ctrl)
//   CustomTextField(
//     hintText: 'City',
//     controller: _ctrl,
//     prefixIcon: Icons.location_city_rounded,
//   )
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
  bool    _isFocused = false;
  String? _errorText;
  bool    _hasText   = false;

  // ── FIX 4+5: Named listener references — required for dispose ─
  late final VoidCallback _focusListener;
  late final VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _focusNode  = widget.focusNode  ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();

    // ── FIX 4: Store as named callback ─────────────────────
    _focusListener = () {
      final focused = _focusNode.hasFocus;
      if (focused != _isFocused) {
        setState(() => _isFocused = focused);
        if (!focused && widget.validator != null) {
          setState(() => _errorText = widget.validator!(_controller.text));
        }
      }
    };

    // ── FIX 5: Store as named callback ─────────────────────
    _controllerListener = () {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
      if (_errorText != null) setState(() => _errorText = null);
    };

    _focusNode.addListener(_focusListener);
    _controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    // ── FIX 4+5: Remove named listeners — no memory leak ───
    _focusNode.removeListener(_focusListener);
    _controller.removeListener(_controllerListener);
    if (widget.focusNode  == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (_errorText != null) return AppTheme.error;
    if (_isFocused) return AppTheme.brandPrimary;
    if (_hasText)   return AppTheme.brandPrimary.withValues(alpha: 0.25);
    return Colors.grey.shade200;
  }

  // ── FIX 1: Constant width — no size jump on focus ─────────
  // Changing 1.5→2 caused AnimatedContainer to physically expand,
  // making the border look doubled and the field edge clip.
  // Color change alone is enough to show focus state.
  double get _borderWidth => 1.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        // ── Input field ───────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // ── FIX 1: Clip overflow from border / shadow ────
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: _borderWidth, // constant 1.5 — no size jump
            ),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color:      AppTheme.brandPrimary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset:     const Offset(0, 4),
              ),
            ]
                : AppTheme.softShadow,
          ),
          child: TextField(
            controller: _controller,
            focusNode:  _focusNode,
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
              fontFamily:  'Poppins',
              fontSize:    14,
              fontWeight:  FontWeight.w600,
              color: widget.enabled
                  ? AppTheme.brandDark
                  : Colors.grey.shade400,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontFamily:  'Poppins',
                fontSize:    14,
                fontWeight:  FontWeight.w400,
                color:       Colors.grey.shade400,
              ),
              // ── FIX 2: All 6 borders explicitly none ──────
              // Missing disabledBorder + focusedErrorBorder were
              // falling back to Flutter's default UnderlineInputBorder
              border:             const OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder:      const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder:      const OutlineInputBorder(borderSide: BorderSide.none),
              errorBorder:        const OutlineInputBorder(borderSide: BorderSide.none),
              focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
              disabledBorder:     const OutlineInputBorder(borderSide: BorderSide.none),
              filled: false,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 4 : 16,
                vertical:   widget.maxLines > 1 ? 14 : 16,
              ),
              counterText: '',
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 4),
                child: Icon(
                  widget.prefixIcon,
                  size:  18,
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

        // ── Error text ────────────────────────────────────
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size:  13,
                  color: AppTheme.error,
                ),
                const SizedBox(width: 5),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    fontFamily:  'Poppins',
                    fontSize:    11,
                    fontWeight:  FontWeight.w500,
                    color:       AppTheme.error,
                  ),
                ),
              ],
            ),
          ),

        // ── Character counter ─────────────────────────────
        if (widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedBuilder(
                animation: _controller,
                // ── FIX 3: was (_, _) — duplicate param ─────
                builder: (_, __) {
                  final count       = _controller.text.length;
                  final limit       = widget.maxLength!;
                  final isNearLimit = count >= (limit * 0.85).round();
                  return Text(
                    '$count / $limit',
                    style: TextStyle(
                      fontFamily:  'Poppins',
                      fontSize:    10,
                      fontWeight:  FontWeight.w500,
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
    if (widget.suffixIcon != null) return widget.suffixIcon;

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
            size:  18,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return null;
  }
}