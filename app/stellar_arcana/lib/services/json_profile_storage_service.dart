import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../widgets/ZodiacInfo.dart';

class JsonProfileStorageService {
  static const String defaultGender = 'F';

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

      if (jsonData['chartData'] is String) {
        jsonData['chartData'] = json.decode(jsonData['chartData']);
      }

      // Si no hay avatar seleccionado, calcular uno basado en el signo zodiacal
      if (jsonData['selectedAvatar'] == null && jsonData['birthDate'] != null) {
        final zodiacInfo = ZodiacInfo(
            birthDate: jsonData['birthDate'],
            gender: jsonData['gender'] ?? defaultGender
        );
        jsonData['selectedAvatar'] = zodiacInfo.getAvatarFilename();
        await saveProfileData(profileName, jsonData);
      }

      return jsonData;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> saveProfileData(String profileName, Map<String, dynamic> newData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$profileName.json');

      // Si el archivo existe, combinar datos existentes con nuevos
      if (await file.exists()) {
        final existingJsonString = await file.readAsString();
        final existingData = json.decode(existingJsonString);
        if (existingData is Map<String, dynamic>) {
          // Combinar datos manteniendo la estructura existente
          final combinedData = {...existingData, ...newData};
          await file.writeAsString(json.encode(combinedData));
          return;
        }
      }

      // Si no existe o hay error, guardar nuevos datos
      await file.writeAsString(json.encode(newData));
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> getAvatarForProfile(String profileName) async {
    try {
      final data = await readProfileData(profileName);
      return data['selectedAvatar'] ?? 'ariesF.webp';
    } catch (e) {
      return 'ariesF.webp';
    }
  }

  static Future<void> updateAvatar(String profileName, String newAvatar) async {
    try {
      final data = await readProfileData(profileName);
      data['selectedAvatar'] = newAvatar;
      await saveProfileData(profileName, {'selectedAvatar': newAvatar});
    } catch (e) {
      rethrow;
    }
  }
}