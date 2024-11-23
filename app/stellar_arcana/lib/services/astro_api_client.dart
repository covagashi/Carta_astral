import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/json_profile_storage_service.dart';
import '../widgets/ZodiacInfo.dart';

class AstroApiClient {
  static const String baseUrl = 'https://covaga.xyz';

  static Future<Map<String, dynamic>> generateChart({
    required String name,
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String country,
    required String province,
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate_carta_natal'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': name,
          'dia': birthDate.day.toString().padLeft(2, '0'),
          'mes': birthDate.month.toString().padLeft(2, '0'),
          'ano': birthDate.year.toString(),
          'hora': birthTime.hour.toString().padLeft(2, '0'),
          'minutos': birthTime.minute.toString().padLeft(2, '0'),
          'pais': country,
          'estado': province,
          'ciudad': city,
          'latitud': latitude.toString(),
          'longitud': longitude.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final zodiacInfo = ZodiacInfo(
            birthDate: birthDate.toIso8601String(),
            gender: 'F'
        );

        final profileData = {
          'chartData': jsonResponse['data'],
          'chartImage': jsonResponse['image'],
          'birthDate': birthDate.toIso8601String(),
          'birthTime': '${birthTime.hour}:${birthTime.minute}',
          'country': country,
          'province': province,
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
          'selectedAvatar': zodiacInfo.getAvatarFilename(),
        };

        await JsonProfileStorageService.saveProfileData(name, profileData);

        return profileData;
      } else {
        throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}