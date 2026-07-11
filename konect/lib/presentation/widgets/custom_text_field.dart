import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24), // 24px standard corner radius
      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000), // Pure black
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF000000), // Pure black
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 15,
              color: Color(0xFF000000), // Pure black
            ),
            fillColor: Color(0xFF000000), // Pure black
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: const Color(0xFF000000), // Pure black
                  )
                : null,
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: borderStyle.copyWith(
              borderSide: BorderSide(
                color: theme.colorScheme.secondaryContainer, // red brand accent
                width: 2,
              ),
            ),
            errorBorder: borderStyle.copyWith(
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: borderStyle.copyWith(
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
