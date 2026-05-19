import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

class ComicCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? color;

  const ComicCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.color,
  });

  @override
  State<ComicCheckbox> createState() => _ComicCheckboxState();
}

class _ComicCheckboxState extends State<ComicCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scale = Tween<double>(begin: 1, end: 1.35)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppColors.electricYellow;
    return GestureDetector(
      onTap: _toggle,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: widget.value ? c : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: c, width: 2.5),
            boxShadow: widget.value
                ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                : [],
          ),
          child: widget.value
              ? const Icon(Icons.check, color: AppColors.bgDeep, size: 18)
              : null,
        ),
      ),
    );
  }
}
