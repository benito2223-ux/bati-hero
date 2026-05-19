import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ComicButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final IconData? icon;
  final bool small;

  const ComicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
    this.small = false,
  });

  @override
  State<ComicButton> createState() => _ComicButtonState();
}

class _ComicButtonState extends State<ComicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppColors.electricYellow;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(_pressed ? 3 : 0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.bgDeep, width: 2),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(color: c.withOpacity(0.7), blurRadius: 0, offset: const Offset(4, 4)),
                  const BoxShadow(color: AppColors.shadowDark, blurRadius: 0, offset: Offset(4, 4)),
                ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.small ? 12 : 20,
          vertical: widget.small ? 8 : 13,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: AppColors.bgDeep, size: widget.small ? 16 : 20),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: GoogleFonts.bangers(
                fontSize: widget.small ? 14 : 18,
                color: AppColors.bgDeep,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
