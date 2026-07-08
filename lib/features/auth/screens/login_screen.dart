import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/power_badge.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.signInWithGoogle();
      // authStateProvider se met à jour → router redirige automatiquement
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn FirebaseAuthException: ${e.code} — ${e.message}');
      setState(() => _error = '[${e.code}] ${e.message ?? "Connexion échouée"}');
    } catch (e) {
      debugPrint('SignIn error: $e');
      setState(() => _error = 'Connexion échouée : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Halftone background
          Positioned.fill(child: CustomPaint(painter: _HalftonePainter())),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricYellow.withOpacity(0.4),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'BÂTI-HERO',
                    style: GoogleFonts.bangers(
                      fontSize: 48,
                      color: AppColors.electricYellow,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: AppColors.electricYellow.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),

                  Text(
                    'TON CHANTIER EN AVENTURE ÉPIQUE',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppColors.neonCyan,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Google Sign-In button
                  if (_loading)
                    const CircularProgressIndicator(color: AppColors.electricYellow)
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F1F1F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo "G" Google (couleurs officielles, sans dépendance réseau)
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Text(
                                'G',
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [
                                        Color(0xFF4285F4),
                                        Color(0xFFEA4335),
                                        Color(0xFFFBBC05),
                                        Color(0xFF34A853),
                                      ],
                                    ).createShader(const Rect.fromLTWH(0, 0, 22, 22)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continuer avec Google',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: GoogleFonts.montserrat(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 48),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      PowerBadge(text: 'SYNC', color: AppColors.neonCyan, fontSize: 16),
                      SizedBox(width: 10),
                      PowerBadge(text: 'COLLAB', color: AppColors.neonPink, fontSize: 16),
                      SizedBox(width: 10),
                      PowerBadge(text: 'MULTI-DEVICE', color: AppColors.electricYellow, fontSize: 14),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tes chantiers synchronisés\nsur tous tes appareils en temps réel',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
