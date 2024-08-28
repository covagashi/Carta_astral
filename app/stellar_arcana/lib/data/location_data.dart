// lib/data/location_data.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Country {
  final String name;
  final String code;
  final String file;

  Country({required this.name, required this.code, required this.file});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      code: json['code'],
      file: json['file'],
    );
  }
}

class LocationData {
  static List<Country>? _countries;
  static Map<String, List<String>> _citiesByCountry = {};

  static Future<void> loadCountryIndex() async {
    if (_countries != null) return;

    final String response = await rootBundle.loadString('assets/countries_index.json');
    final data = await json.decode(response);
    
    _countries = (data['countries'] as List)
        .map((countryJson) => Country.fromJson(countryJson))
        .toList();
  }

  static List<String> getCountryNames() {
    return _countries?.map((country) => country.name).toList() ?? [];
  }

  static String? getCountryCodeByName(String countryName) {
    return _countries?.firstWhere((country) => country.name == countryName).code;
  }

  static Future<List<String>> getCitiesForCountry(String countryCode) async {
    if (_citiesByCountry.containsKey(countryCode)) {
      return _citiesByCountry[countryCode]!;
    }

    final country = _countries?.firstWhere((country) => country.code == countryCode);
    if (country == null) return [];

    final String response = await rootBundle.loadString('assets/countries/${country.file}');
    final data = await json.decode(response);
    
    List<String> cities = [];
    for (var province in data['provinces']) {
      cities.addAll(province['cities'].map((city) => city['name'] as String));
    }

    _citiesByCountry[countryCode] = cities;
    return cities;
  }
}