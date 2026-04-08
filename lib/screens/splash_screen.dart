import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/poster_grid_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.onExplore});

  final VoidCallback onExplore;

  static const Color _btnTeal = Color(0xFF005B6E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2D2E),
      body: SafeArea(
        child: PosterGridBackground(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 5),  // ← dinaikkan dari 2 ke 4, tulisan turun
                Text(
                  'MyDrama',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dancingScript(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'with this application, you can search whats the most KDrama',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const Spacer(flex: 3),  // ← tetap sama
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onExplore,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _btnTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'lets explore!!',
                      style: GoogleFonts.merriweather(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}