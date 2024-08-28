// lib/screens/location_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/location_data.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  String? selectedCountry;
  String? selectedCity;
  List<String> filteredCountries = [];
  List<String> filteredCities = [];

  @override
  void initState() {
    super.initState();
    filteredCountries = LocationData.getCountryNames();
  }

  void filterCountries(String query) {
    setState(() {
      filteredCountries = LocationData.getCountryNames()
          .where((country) => country.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void filterCities(String query) {
    if (selectedCountry == null) return;
    String countryCode = LocationData.getCountryCodeByName(selectedCountry!)!;
    setState(() {
      filteredCities = LocationData.getCitiesForCountry(countryCode)
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40),
          Text(
            "¿DÓNDE NACISTE?",
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
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
          SizedBox(height: 20),
          Text(
            "Tu lugar de nacimiento es crucial para calcular tu carta astral con precisión.",
            textAlign: TextAlign.center,
            style: GoogleFonts.comfortaa(
              textStyle: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          SizedBox(height: 40),
          TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar país...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: filterCountries,
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredCountries[index],
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() {
                      selectedCountry = filteredCountries[index];
                      selectedCity = null;
                      filteredCities = LocationData.getCitiesForCountry(
                          LocationData.getCountryCodeByName(selectedCountry!)!);
                    });
                  },
                );
              },
            ),
          ),
          if (selectedCountry != null) ...[
            SizedBox(height: 20),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar ciudad...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: filterCities,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCities.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      filteredCities[index],
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        selectedCity = filteredCities[index];
                      });
                      print('País seleccionado: $selectedCountry, Ciudad seleccionada: $selectedCity');
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}