import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';
import '../widgets/custom_date_picker.dart';

class BirthInfo extends StatefulWidget {
  final String backgroundImagePath;

  BirthInfo({Key? key, required this.backgroundImagePath}) : super(key: key);

  @override
  _BirthInfoState createState() => _BirthInfoState();
}

class _BirthInfoState extends State<BirthInfo> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool unknownTime = false;

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: widget.backgroundImagePath,
        child: SafeArea(
          child: SingleChildScrollView(
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
                    "Tu fecha y hora de nacimiento son esenciales para crear tu carta natal precisa.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.comfortaa(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  // Date Picker
                  Container(
                    height: 200,
                    child: CustomWheelDatePicker(
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  // Time Picker
                  Text(
                    "Hora de nacimiento",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (!unknownTime)
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          selectedTime?.format(context) ?? 'Seleccionar hora',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      // Navegar a la siguiente pantalla
                      print("Fecha seleccionada: $selectedDate");
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
                  SizedBox(height: 60), // Espacio para el banner de anuncios
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[800],
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
}
