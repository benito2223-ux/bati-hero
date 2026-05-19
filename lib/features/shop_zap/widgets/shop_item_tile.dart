import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shopping_item.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/comic_checkbox.dart';

class ShopItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ShopItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.checked ? AppColors.bgDeep : AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.checked
              ? AppColors.textSecondary.withOpacity(0.2)
              : AppColors.electricYellow.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ComicCheckbox(value: item.checked, onChanged: (_) => onToggle()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: item.checked ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
                if (item.quantity != '1')
                  Text(
                    item.quantity,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.neonCyan.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded, color: AppColors.danger, size: 18),
          ),
        ],
      ),
    );
  }
}
