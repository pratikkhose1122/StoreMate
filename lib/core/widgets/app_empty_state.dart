import 'package:flutter/material.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';

/// Minimal empty state: icon + title + explanation + action.
/// No decorative elements. Generous whitespace.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String explanation;
  final String actionLabel;
  final VoidCallback onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.explanation,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTextStyles.productLg.copyWith(
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: AppTextStyles.bodyMd.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 44),
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                actionLabel,
                style: AppTextStyles.labelMd.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
