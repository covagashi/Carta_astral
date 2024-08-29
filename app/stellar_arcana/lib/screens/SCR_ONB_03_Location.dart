import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/location_selector.dart';
import '../widgets/parallax_background.dart';


class LocationScreen extends StatelessWidget {
  final String backgroundImagePath;
  final DateTime birthDate;
  final TimeOfDay birthTime;

  LocationScreen({
    Key? key,
    required this.backgroundImagePath,
    required this.birthDate,
    required this.birthTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: backgroundImagePath,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Text(
                  "¿DÓNDE NACISTE?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
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
                SizedBox(height: 20),
                Text(
                  "Tu lugar de nacimiento es crucial para calcular tu carta astral con precisión.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Expanded(
                  child: LocationSelector(
                    backgroundImagePath: backgroundImagePath,
                    birthDate: birthDate,
                    birthTime: birthTime,
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