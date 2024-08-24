import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late String backgroundImagePath;

  @override
  void initState() {
    super.initState();
    _selectRandomBackground();
    _navigateToMainScreen();
  }

  void _selectRandomBackground() {
    final random = Random();
    final imageNumber = random.nextInt(5) + 1;
    backgroundImagePath = 'assets/splash$imageNumber.webp';
  }

  void _navigateToMainScreen() {
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: backgroundImagePath,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "STELLAR ARCANA",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "INSIGHTS",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}