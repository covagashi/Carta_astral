import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'SCR_01_Home.dart';
import '../services/json_profile_storage_service.dart';

class Confirmation extends StatelessWidget {
  final String backgroundImagePath;
  final DateTime birthDate;
  final TimeOfDay birthTime;
  final String country;
  final String province;
  final String city;

  Confirmation({
    Key? key,
    required this.backgroundImagePath,
    required this.birthDate,
    required this.birthTime,
    required this.country,
    required this.province,
    required this.city,
  }) : super(key: key);

  Future<void> _generateChart(BuildContext context) async {
    try {
      print('Iniciando generación de carta astral');
      final url = Uri.parse('http://10.0.2.2:5000/generate_carta_natal');
      print('URL del servidor: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': 'Espíritu Estelar',  // Nombre del perfil
          'dia': birthDate.day.toString().padLeft(2, '0'),
          'mes': birthDate.month.toString().padLeft(2, '0'),
          'ano': birthDate.year.toString(),
          'hora': birthTime.hour.toString().padLeft(2, '0'),
          'minutos': birthTime.minute.toString().padLeft(2, '0'),
          'pais': country,
          'estado': province,
          'ciudad': city,
        }),
      );

      print('Respuesta recibida. Código de estado: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('Respuesta JSON recibida: ${jsonResponse.toString().substring(0, 100)}...');

        // Guardar los datos en un archivo JSON asociado al perfil
        await JsonProfileStorageService.saveProfileData('Espíritu Estelar', {
          'chartData': jsonResponse['data'],
          'birthDate': birthDate.toIso8601String(),
          'birthTime': '${birthTime.hour}:${birthTime.minute}',
          'country': country,
          'province': province,
          'city': city,
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(profileName: 'Espíritu Estelar'),
          ),
        );
      } else {
        throw Exception('Failed to generate chart: ${response.statusCode}');
      }
    } catch (e) {
      print('Error detallado: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar la carta astral: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: backgroundImagePath,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20),
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
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
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
                        SizedBox(height: 20),
                        _buildInfoCard("Nombre", "Espíritu Estelar"),
                        _buildInfoCard("Fecha de Nacimiento", "${birthDate.day}/${birthDate.month}/${birthDate.year}"),
                        _buildInfoCard("Hora de Nacimiento", "${birthTime.format(context)}"),
                        _buildInfoCard("País", country),
                        _buildInfoCard("Provincia", province),
                        _buildInfoCard("Ciudad", city),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _generateChart(context),  // Modificado aquí
                          child: Text(
                            "GENERAR CARTA ASTRAL",
                            style: GoogleFonts.comfortaa(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
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
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                textStyle: TextStyle(
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