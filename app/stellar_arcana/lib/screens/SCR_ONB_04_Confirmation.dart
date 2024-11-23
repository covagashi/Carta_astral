import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';
import 'SCR_ONB_05_LoadingAnimation.dart';
import 'SCR_01_Home.dart';
import '../services/astro_api_client.dart';

class Confirmation extends StatefulWidget {
  final String backgroundImagePath;
  final DateTime birthDate;
  final TimeOfDay birthTime;
  final String country;
  final String province;
  final String city;
  final double latitude;
  final double longitude;

  const Confirmation({
    super.key,
    required this.backgroundImagePath,
    required this.birthDate,
    required this.birthTime,
    required this.country,
    required this.province,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Espíritu Estelar');
  final String serverUrl = 'https://covaga.xyz/generate_carta_natal';


  Future<void> _generateChart(BuildContext context) async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre para tu perfil.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingAnimation(profileName: _nameController.text),
      ),
    );

    try {
      final chartData = await AstroApiClient.generateChart(
        name: _nameController.text,
        birthDate: widget.birthDate,
        birthTime: widget.birthTime,
        country: widget.country,
        province: widget.province,
        city: widget.city,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeContainer(profileName: _nameController.text),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar la carta astral: $e'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: widget.backgroundImagePath,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "CONFIRMA TUS DATOS",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
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
                        const SizedBox(height: 10),
                        Text(
                          "Verifica que la información sea correcta",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Perfil',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInfoCard("Fecha de Nacimiento",
                            "${widget.birthDate.day}/${widget.birthDate.month}/${widget.birthDate.year}"),
                        _buildInfoCard("Hora de Nacimiento",
                            widget.birthTime.format(context)),
                        _buildInfoCard("País", widget.country),
                        _buildInfoCard("Provincia", widget.province),
                        _buildInfoCard("Ciudad", widget.city),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _generateChart(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "GENERAR CARTA ASTRAL",
                            style: GoogleFonts.comfortaa(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Espacio para publicidad
              Container(
                height: 60,
                color: Colors.white.withOpacity(0.1),
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

  Widget _buildInfoCard(String label, String value) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Text(
              value,
              style: GoogleFonts.comfortaa(
                textStyle: const TextStyle(
                  fontSize: 14,
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
