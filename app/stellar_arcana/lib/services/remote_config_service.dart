import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final remoteConfig = FirebaseRemoteConfig.instance;

  Future<bool> initialize() async {
    try {
      // Configurar los ajustes de Remote Config
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Establecer valores por defecto
      await remoteConfig.setDefaults(const {
        "youtube_api_key": "", // Valor por defecto
      });

      // Forzar la obtención de valores nuevos
      await remoteConfig.fetch();


      // Activar los valores obtenidos
      final activated = await remoteConfig.activate();

      debugPrint('Remote Config inicializado');
      debugPrint('¿Fetch exitoso?: $activated');

      // Verificar el valor de la API key
      final apiKey = remoteConfig.getString('youtube_api_key');
      debugPrint('Valor actual de API key: ${apiKey.length} caracteres');
      debugPrint('YouTube API Key obtenida: ${apiKey.isEmpty ? "vacía" : "presente"}');

      return activated;
    } catch (e) {
      debugPrint('Error en Remote Config: $e');
      return false;
    }
  }


  String get youtubeApiKey {
    final apiKey = remoteConfig.getString('youtube_api_key');
    debugPrint('RemoteConfig API Key length: ${apiKey.length}');
    return apiKey;
  }
}