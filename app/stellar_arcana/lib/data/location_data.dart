// lib/data/location_data.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocationData {
  static Map<String, dynamic>? _countryData;

  static Future<void> loadCountryIndex() async {
    if (_countryData != null) return;

    try {
      final String response = await rootBundle.loadString('assets/countries_index.json');
      _countryData = json.decode(response);
    } catch (e) {
      print('Error loading country index: $e');
      _countryData = {"countries": []};
    }
  }

  static List<String> getCountryNames() {
    if (_countryData == null) {
      return [];
    }
    return (_countryData!['countries'] as List)
        .map((country) => country['name'] as String)
        .toList();
  }

  static String? getCountryCodeByName(String countryName) {
    if (_countryData == null) return null;
    var country = _countryData!['countries'].firstWhere(
            (c) => c['name'].toLowerCase() == countryName.toLowerCase(),
        orElse: () => null
    );
    return country?['code'];
  }

  static Future<List<String>> getCitiesForCountry(String countryCode) async {
    if (_countryData == null) await loadCountryIndex();
    var country = _countryData!['countries'].firstWhere(
            (c) => c['code'] == countryCode,
        orElse: () => null
    );
    if (country == null) return [];

    try {
      final String response = await rootBundle.loadString('assets/countries/${country['file']}');
      final data = json.decode(response);

      List<String> cities = [];
      for (var province in data['provinces']) {
        cities.addAll(province['cities'].map((city) => city['name'] as String));
      }

      return cities;
    } catch (e) {
      print('Error loading cities for country $countryCode: $e');
      return [];
    }
  }
}