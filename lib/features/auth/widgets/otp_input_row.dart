import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class OtpInputRow extends StatelessWidget {
  const OtpInputRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.isError,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isError;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _OtpBox(
        controller: controllers[i],
        focusNode: focusNodes[i],
        isError: isError,
        onChanged: (val) => onChanged(i, val),
      )),
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

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 44, height: 54,
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
          width: _isFocused ? 2 : 1.5,
        ),
        boxShadow: _isFocused && !widget.isError
            ? [BoxShadow(
          color: AppTheme.brandPrimary.withValues(alpha: 0.15),
          blurRadius: 10, offset: const Offset(0, 3),
        )]
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


// ============================================================
// 📋 AUTH BOTTOM TEXT
// Terms of Service + Privacy Policy — shared by all auth screens
// ============================================================