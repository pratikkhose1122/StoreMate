import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, subtle, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isFullWidth;
  final bool isLoading;
  final bool isSmall;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isFullWidth = true,
    this.isLoading = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color backgroundColor;
    Color textColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.primary;
        textColor = colors.primaryForeground;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        textColor = colors.textPrimary;
        borderSide = BorderSide(color: colors.border, width: 1);
        break;
      case AppButtonVariant.subtle:
        backgroundColor = colors.elevatedCard;
        textColor = colors.textPrimary;
        break;
      case AppButtonVariant.danger:
        backgroundColor = colors.danger;
        textColor = Colors.white;
        break;
    }

    final verticalPadding = isSmall ? 10.0 : 14.0;
    final horizontalPadding = isSmall ? 16.0 : 20.0;
    final textStyle = isSmall ? AppTextStyles.labelMd : AppTextStyles.btnMd;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor,
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: isSmall ? 16 : 18, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(text, style: textStyle.copyWith(color: textColor)),
      ],
    );

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed?.call();
              },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          width: isFullWidth ? double.infinity : null,
          decoration: borderSide != null
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: borderSide.color,
                    width: borderSide.width,
                  ),
                )
              : null,
          child: content,
        ),
      ),
    );
  }
}
