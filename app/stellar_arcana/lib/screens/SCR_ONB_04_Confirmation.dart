import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SCR_ONB_05_LoadingAnimation.dart';
import 'SCR_01_Home.dart';
import '../services/json_profile_storage_service.dart';

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

    // Navegar inmediatamente a la pantalla de carga
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LoadingAnimation(profileName: _nameController.text),
      ),
    );

    // Iniciar el proceso de generación de la carta astral en segundo plano
    try {
      print('Iniciando generación de carta astral');
      final url = Uri.parse(serverUrl);
      print('URL del servidor: $url');

      final client = http.Client();
      final response = await client
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'nombre': _nameController.text,
          'dia': widget.birthDate.day.toString().padLeft(2, '0'),
          'mes': widget.birthDate.month.toString().padLeft(2, '0'),
          'ano': widget.birthDate.year.toString(),
          'hora': widget.birthTime.hour.toString().padLeft(2, '0'),
          'minutos': widget.birthTime.minute.toString().padLeft(2, '0'),
          'pais': widget.country,
          'estado': widget.province,
          'ciudad': widget.city,
          'latitud': widget.latitude.toString(),
          'longitud': widget.longitude.toString(),
        }),
      )
          .timeout(
        const Duration(minutes: 1), // Aumenta el timeout a 1 minuto
        onTimeout: () {
          client.close();
          throw Exception('Tiempo de espera agotado');
        },
      );

      print('Respuesta recibida. Código de estado: ${response.statusCode}');
      client.close();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(
            'Respuesta JSON recibida: ${jsonResponse.toString().substring(0, 100)}...');

        // Guardar los datos en un archivo JSON asociado al perfil
        await JsonProfileStorageService.saveProfileData(_nameController.text, {
          'chartData': jsonResponse['data'],
          'chartImage': jsonResponse['image'],
          'birthDate': widget.birthDate.toIso8601String(),
          'birthTime': '${widget.birthTime.hour}:${widget.birthTime.minute}',
          'country': widget.country,
          'province': widget.province,
          'city': widget.city,
          'latitude': widget.latitude, // Añadimos la latitud
          'longitude': widget.longitude, // Añadimos la longitud
        });

        // Navegar a la pantalla principal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeContainer(profileName: _nameController.text),
          ),
        );
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error detallado: $e');
      // Mostrar error y volver a la pantalla anterior
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Error al generar la carta astral. Por favor, intenta nuevamente.'),
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
