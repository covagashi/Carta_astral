import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';

class Confirmation extends StatelessWidget {
  final String backgroundImagePath;
  final String name;
  final DateTime birthDate;
  final TimeOfDay birthTime;
  final String country;
  final String province;
  final String city;

  Confirmation({
    Key? key,
    required this.backgroundImagePath,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.country,
    required this.province,
    required this.city,
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
                  "CONFIRMA TUS DATOS",
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
                  "Por favor, verifica que toda la información sea correcta antes de continuar.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                _buildInfoCard("Nombre", name),
                _buildInfoCard("Fecha de Nacimiento", "${birthDate.day}/${birthDate.month}/${birthDate.year}"),
                _buildInfoCard("Hora de Nacimiento", "${birthTime.hour}:${birthTime.minute.toString().padLeft(2, '0')}"),
                _buildInfoCard("País", country),
                _buildInfoCard("Provincia", province),
                _buildInfoCard("Ciudad", city),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Aquí iría la lógica para generar la carta astral
                    // y navegar a la pantalla principal de la app
                    print("Generando carta astral...");
                  },
                  child: Text(
                    "GENERAR CARTA ASTRAL",
                    style: GoogleFonts.comfortaa(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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

  Widget _buildInfoCard(String label, String value) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.comfortaa(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.comfortaa(
                textStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
