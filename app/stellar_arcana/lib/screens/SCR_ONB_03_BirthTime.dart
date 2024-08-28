import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';

class BirthTime extends StatefulWidget {
  final String backgroundImagePath;

  BirthTime({Key? key, required this.backgroundImagePath}) : super(key: key);

  @override
  _BirthTimeState createState() => _BirthTimeState();
}

class _BirthTimeState extends State<BirthTime> {
  TimeOfDay? selectedTime;
  bool unknownTime = false;

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
                  "¿A qué hora naciste?",
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
                  "La hora de nacimiento es crucial para determinar tu ascendente y las casas astrológicas.",
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!unknownTime)
                          SizedBox(
                            height: 150,
                            child: CupertinoTheme(
                              data: CupertinoThemeData(
                                textTheme: CupertinoTextThemeData(
                                  pickerTextStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                onDateTimeChanged: (DateTime dateTime) {
                                  setState(() {
                                    selectedTime = TimeOfDay.fromDateTime(dateTime);
                                  });
                                },
                                use24hFormat: true,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No conozco la hora exacta",
                              style: GoogleFonts.comfortaa(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Switch(
                              value: unknownTime,
                              onChanged: (value) {
                                setState(() {
                                  unknownTime = value;
                                  if (value) {
                                    selectedTime = null;
                                  }
                                });
                              },
                              activeColor: Colors.white.withOpacity(0.8),
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 60), // Espacio para el banner de anuncios
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a la siguiente pantalla
                      print("Hora seleccionada: ${unknownTime ? 'Desconocida' : selectedTime?.format(context)}");
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
