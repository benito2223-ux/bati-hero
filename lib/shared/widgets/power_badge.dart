import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class PowerBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;

  const PowerBadge({
    super.key,
    required this.text,
    this.color,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.electricYellow;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.55,
        vertical: fontSize * 0.18,
      ),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.bgDeep, width: 2.5),
        boxShadow: [
          BoxShadow(color: c.withOpacity(0.7), blurRadius: 14, spreadRadius: 2),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.bangers(
          fontSize: fontSize,
          color: AppColors.bgDeep,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
