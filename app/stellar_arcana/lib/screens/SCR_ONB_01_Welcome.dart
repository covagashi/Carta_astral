import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';

class Welcome extends StatelessWidget {
  final String backgroundImagePath;

  Welcome({Key? key, required this.backgroundImagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: backgroundImagePath,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                        SizedBox(height: 24),
                        Text(
                          "Explora tu destino a través de tu carta natal",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 20,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      // Lógica para navegar a la siguiente pantalla
                    },
                    child: Text(
                      "EXPLORAR",
                      style: GoogleFonts.comfortaa(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
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