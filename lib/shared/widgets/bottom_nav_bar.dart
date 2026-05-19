import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../features/projects/providers/project_provider.dart';

// AppBar globale avec logo
class HeroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? titleColor;

  const HeroAppBar({
    super.key,
    required this.title,
    this.actions,
    this.titleColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.bangers(
          fontSize: 26,
          color: titleColor ?? AppColors.electricYellow,
          letterSpacing: 1.5,
        ),
      ),
      actions: actions,
    );
  }
}

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  static const _tabs = [
    _TabInfo(icon: Icons.shopping_cart_rounded, label: 'SHOP-ZAP', color: AppColors.electricYellow),
    _TabInfo(icon: Icons.bolt_rounded, label: 'MONEY', color: AppColors.neonPink),
    _TabInfo(icon: Icons.calendar_month_rounded, label: 'CHRONO', color: AppColors.neonCyan),
    _TabInfo(icon: Icons.photo_camera_rounded, label: 'HERO-FEED', color: AppColors.neonPink),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProject = ref.watch(currentProjectProvider);

    return Scaffold(
      body: Column(
        children: [
          // Project context banner
          if (currentProject != null)
            GestureDetector(
              onTap: () => context.go('/'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: currentProject.color.withOpacity(0.12),
                child: Row(
                  children: [
                    Text(currentProject.emoji,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentProject.name.toUpperCase(),
                        style: GoogleFonts.bangers(
                          fontSize: 13,
                          color: currentProject.color,
                          letterSpacing: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.swap_horiz_rounded,
                        color: currentProject.color, size: 16),
                    const SizedBox(width: 4),
                    Text('CHANGER',
                        style: GoogleFonts.bangers(
                            fontSize: 11, color: currentProject.color)),
                  ],
                ),
              ),
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgDeep,
          border: Border(top: BorderSide(color: AppColors.electricYellow, width: 2)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final tab = _tabs[i];
                final selected = navigationShell.currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => navigationShell.goBranch(
                      i,
                      initialLocation: i == navigationShell.currentIndex,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        border: Border(
                          top: selected
                              ? BorderSide(color: tab.color, width: 3)
                              : BorderSide.none,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tab.icon,
                            color: selected ? tab.color : AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: GoogleFonts.bangers(
                              fontSize: 10,
                              color: selected ? tab.color : AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;
  final Color color;
  const _TabInfo({required this.icon, required this.label, required this.color});
}
