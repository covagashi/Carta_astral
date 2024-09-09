import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JsonProfileStorageService {
  static Future<Map<String, dynamic>> readProfileData(String profileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$profileName.json');

      if (!await file.exists()) {
        throw Exception('El archivo del perfil no existe');
      }

      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);

      if (jsonData is! Map<String, dynamic>) {
        throw Exception('El formato del archivo JSON no es válido');
      }

      // Asegurarse de que 'chartData' es un Map y no un String
      if (jsonData['chartData'] is String) {
        jsonData['chartData'] = json.decode(jsonData['chartData']);
      }

      if (jsonData['image'] != null) {
        print('Longitud de la imagen base64 leída: ${jsonData['image'].length}');
      } else {
        print('No se encontró imagen base64 en los datos del perfil');
      }

      return jsonData;
    } catch (e) {
      print('Error al leer los datos del perfil: $e');
      rethrow;
    }
  }

  static Future<void> saveProfileData(String profileName, Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$profileName.json');
    await file.writeAsString(json.encode(data));
  }
}