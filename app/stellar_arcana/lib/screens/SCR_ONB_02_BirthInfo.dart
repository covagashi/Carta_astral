import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';
import '../widgets/custom_date_picker.dart';
import 'SCR_ONB_03_Location.dart';


class BirthInfo extends StatefulWidget {
  final String backgroundImagePath;

  const BirthInfo({
    super.key,
    required this.backgroundImagePath,
  });

  @override
  _BirthInfoState createState() => _BirthInfoState();
}

class _BirthInfoState extends State<BirthInfo> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool unknownTime = false;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.now();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: widget.backgroundImagePath,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildBirthInfoPage(),
                    LocationScreen(
                      backgroundImagePath: widget.backgroundImagePath,
                      birthDate: selectedDate ?? DateTime.now(),
                      birthTime: selectedTime ?? TimeOfDay.now(),
                    ),
                  ],
                ),
              ),
              // Indicador de puntos deslizables
              SizedBox(
                height: 50,
                child: _buildPageIndicator(),
              ),
              // Espacio reservado para publicidad
              Container(
                height: 60,
                color: Colors.transparent,
                child: Center(
                  child: Text(
                    'Espacio para publicidad',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthInfoPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              "¿CUÁNDO NACISTE?",
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
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 40),
            // Date Picker
            SizedBox(
              height: 200,
              child: CustomWheelDatePicker(
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ),
            const SizedBox(height: 40),
            // Time Picker
            Text(
              "HORA DE NACIMIENTO",
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!unknownTime)
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    selectedTime?.format(context) ?? 'Seleccionar hora',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No conozco la hora exacta",
                  style: GoogleFonts.comfortaa(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: unknownTime,
                  onChanged: (value) {
                    setState(() {
                      unknownTime = value;
                      if (value) {
                        selectedTime = const TimeOfDay(hour: 12, minute: 0); // Establecer a 12:00
                      } else {
                        selectedTime = TimeOfDay.now(); // Restablecer a la hora actual
                      }
                    });
                  },
                  activeColor: Colors.white.withOpacity(0.8),
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          },
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.4),
            ),
          ),
        );
      }),
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