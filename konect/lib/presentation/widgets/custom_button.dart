import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Red brand primary action color (#e21e49)
    final Color defaultPrimaryBg = theme.colorScheme.secondaryContainer;
    const Color defaultPrimaryText = Colors.white;

    // Secondary: outline-style
    const Color defaultSecondaryBg = Colors.transparent;
    final Color defaultSecondaryText = theme.colorScheme.secondaryContainer; // Red

    Color finalBgColor;
    Color finalTextColor;
    BorderSide borderSide = BorderSide.none;

    if (isPrimary) {
      finalBgColor = backgroundColor ?? defaultPrimaryBg;
      finalTextColor = textColor ?? defaultPrimaryText;
    } else {
      finalBgColor = backgroundColor ?? defaultSecondaryBg;
      finalTextColor = textColor ?? defaultSecondaryText;
      borderSide = BorderSide(
        color: textColor ?? defaultSecondaryText,
        width: 2.0,
      );
    }

    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: finalTextColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: finalTextColor,
          ),
        ),
      ],
    );

    final buttonStyle = TextButton.styleFrom(
      backgroundColor: finalBgColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // 24px rounded standard
        side: borderSide,
      ),
      elevation: 0,
    );

    Widget result = TextButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: buttonChild,
    );

    if (isFullWidth) {
      result = SizedBox(
        width: double.infinity,
        child: result,
      );
    }

    return result;
  }
}

