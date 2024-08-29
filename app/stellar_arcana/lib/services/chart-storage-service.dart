import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChartStorageService {
  static const String _prefix = 'chart_data_';

  // Guarda los datos de la carta astral para un perfil específico
  static Future<bool> saveChartData(String profileName, String chartData) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('$_prefix$profileName', chartData);
  }

  // Recupera los datos de la carta astral para un perfil específico
  static Future<String?> getChartData(String profileName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$profileName');
  }

  // Verifica si existen datos guardados para un perfil específico
  static Future<bool> hasChartData(String profileName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_prefix$profileName');
  }

  // Elimina los datos de la carta astral para un perfil específico
  static Future<bool> removeChartData(String profileName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('$_prefix$profileName');
  }
}
