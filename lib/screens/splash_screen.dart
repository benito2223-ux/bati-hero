import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../shared/widgets/power_badge.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _titleCtrl;
  late final AnimationController _badgeCtrl;
  late final Animation<double> _titleScale;
  late final Animation<double> _badgeOpacity;

  @override
  void initState() {
    super.initState();
    _titleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _badgeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _titleScale = Tween<double>(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.elasticOut));
    _badgeOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeIn));
    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _titleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _badgeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HalftonePainter())),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _titleScale,
                  child: Column(
                    children: [
                      // Logo principal
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricYellow.withOpacity(0.4),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: AppColors.neonPink.withOpacity(0.2),
                              blurRadius: 48,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'TON CHANTIER EN AVENTURE ÉPIQUE',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: AppColors.neonCyan,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 52),
                FadeTransition(
                  opacity: _badgeOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      PowerBadge(text: 'POW!', color: AppColors.electricYellow, fontSize: 22),
                      SizedBox(width: 12),
                      PowerBadge(text: 'BAM!', color: AppColors.neonPink, fontSize: 22),
                      SizedBox(width: 12),
                      PowerBadge(text: 'BOOM!', color: AppColors.neonCyan, fontSize: 22),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HalftonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.electricYellow.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
