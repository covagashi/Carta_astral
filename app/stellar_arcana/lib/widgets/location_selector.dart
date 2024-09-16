import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../screens/SCR_ONB_04_Confirmation.dart';


class LocationSelector extends StatefulWidget {
  final String backgroundImagePath;
  final DateTime birthDate;
  final TimeOfDay birthTime;

  LocationSelector({
    Key? key,
    required this.backgroundImagePath,
    required this.birthDate,
    required this.birthTime,
  }) : super(key: key);

  @override
  _LocationSelectorState createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  List<String> countries = [];
  List<String> provinces = [];
  List<String> cities = [];
  String? selectedCountry;
  String? selectedProvince;
  String? selectedCity;
  double? selectedLatitude;
  double? selectedLongitude;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final String response = await rootBundle.loadString('assets/countries_index.json');
      final data = json.decode(response);
      setState(() {
        countries = List<String>.from(data['countries'].map((country) => country['name']));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar los países: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _loadProvinces(String countryName) async {
    setState(() {
      isLoading = true;
      provinces = [];
      cities = [];
      selectedProvince = null;
      selectedCity = null;
    });

    try {
      final String indexResponse = await rootBundle.loadString('assets/countries_index.json');
      final indexData = json.decode(indexResponse);
      final countryData = indexData['countries'].firstWhere((c) => c['name'] == countryName);

      final String countryResponse = await rootBundle.loadString('assets/countries/${countryData['file']}');
      final countryJson = json.decode(countryResponse);

      setState(() {
        provinces = List<String>.from(countryJson['provinces'].map((province) => province['name']));
        // Si el país tiene latitud y longitud, las guardamos
        if (countryJson['latitude'] != null && countryJson['longitude'] != null) {
          selectedLatitude = countryJson['latitude'];
          selectedLongitude = countryJson['longitude'];
        } else {
          selectedLatitude = null;
          selectedLongitude = null;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar las provincias: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _loadCities(String provinceName) async {
    setState(() {
      isLoading = true;
      cities = [];
      selectedCity = null;
    });

    try {
      final String indexResponse = await rootBundle.loadString('assets/countries_index.json');
      final indexData = json.decode(indexResponse);
      final countryData = indexData['countries'].firstWhere((c) => c['name'] == selectedCountry);

      final String countryResponse = await rootBundle.loadString('assets/countries/${countryData['file']}');
      final countryJson = json.decode(countryResponse);

      final provinceData = countryJson['provinces'].firstWhere((p) => p['name'] == provinceName);

      setState(() {
        if (provinceData['cities'] != null && provinceData['cities'].isNotEmpty) {
          cities = List<String>.from(provinceData['cities'].map((city) => city['name']));
        } else {
          cities = [provinceName];
          selectedCity = provinceName;
        }
        // Actualizamos la latitud y longitud de la provincia
        selectedLatitude = provinceData['latitude'];
        selectedLongitude = provinceData['longitude'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar las ciudades: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red))
            else ...[
                DropdownButton<String>(
                  value: selectedCountry,
                  hint: Text('Selecciona un país', style: TextStyle(color: Colors.white70)),
                  isExpanded: true,
                  dropdownColor: Colors.grey[800],
                  style: TextStyle(color: Colors.white),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCountry = newValue;
                      selectedProvince = null;
                      selectedCity = null;
                    });
                    if (newValue != null) {
                      _loadProvinces(newValue);
                    }
                  },
                  items: countries.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                if (selectedCountry != null) ...[
                  DropdownButton<String>(
                    value: selectedProvince,
                    hint: Text('Selecciona una provincia o ciudad', style: TextStyle(color: Colors.white70)),
                    isExpanded: true,
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(color: Colors.white),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProvince = newValue;
                        selectedCity = null;
                      });
                      if (newValue != null) {
                        _loadCities(newValue);
                      }
                    },
                    items: provinces.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                ],
                if (selectedProvince != null && cities.isNotEmpty) ...[
                  DropdownButton<String>(
                    value: selectedCity,
                    hint: Text('Selecciona una ciudad', style: TextStyle(color: Colors.white70)),
                    isExpanded: true,
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(color: Colors.white),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCity = newValue;
                      });
                    },
                    items: cities.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                ],
                if (selectedCountry != null && selectedProvince != null &&
                    (selectedCity != null || cities.isEmpty)) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Confirmation(
                            backgroundImagePath: widget.backgroundImagePath,
                            birthDate: widget.birthDate,
                            birthTime: widget.birthTime,
                            country: selectedCountry!,
                            province: selectedProvince!,
                            city: selectedCity ?? selectedProvince!,
                            latitude: selectedLatitude ?? 0.0,  // Agregamos la latitud
                            longitude: selectedLongitude ?? 0.0,  // Agregamos la longitud
                          ),
                        ),
                      );
                    },
                    child: Text('Confirmar ubicación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ],
          ],
        ),
      ),
    );
  }
}