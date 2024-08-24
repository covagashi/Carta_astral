import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';
import '../widgets/custom_date_picker.dart';

class Birthdate extends StatefulWidget {
  final String backgroundImagePath;

  Birthdate({Key? key, required this.backgroundImagePath}) : super(key: key);

  @override
  _BirthdateState createState() => _BirthdateState();
}

class _BirthdateState extends State<Birthdate> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: widget.backgroundImagePath,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Text(
                  "¿Cuándo naciste?",
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
                  "Tu fecha de nacimiento es esencial para crear tu carta natal precisa.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: CustomWheelDatePicker(
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),
                ),
                if (selectedDate != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 60), // Espacio para el banner de anuncios
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar a la siguiente pantalla
                        print("Fecha seleccionada: $selectedDate");
                      },
                      child: Text(
                        "CONTINUAR",
                        style: GoogleFonts.lato(
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
                        padding: EdgeInsets.symmetric(vertical: 15),
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