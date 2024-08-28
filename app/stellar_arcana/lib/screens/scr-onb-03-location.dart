import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          // Aquí puedes agregar un widget de búsqueda de ubicación
          // Por ahora, usaremos un simple TextField como placeholder
          TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar ciudad...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                selectedLocation = value;
              });
            },
          ),
          // Aquí puedes agregar una lista de resultados de búsqueda
        ],
      ),
    );
  }
}
