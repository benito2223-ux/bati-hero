import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ComicCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const ComicCard({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.electricYellow;
    final content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
        boxShadow: [
          BoxShadow(
            color: border.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
          const BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 4,
            offset: Offset(-1, -1),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return content;
  }
}
