import 'package:flutter/material.dart';
import '../data/location_data.dart';


class Location extends StatefulWidget {
  final String backgroundImagePath;

  Location({Key? key, required this.backgroundImagePath}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  String? selectedCountry;
  String? selectedCity;
  List<String> filteredCountries = [];
  List<String> filteredCities = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCountryData();
  }

  Future<void> _loadCountryData() async {
    try {
      await LocationData.loadCountryIndex();
      setState(() {
        filteredCountries = LocationData.getCountryNames();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar los datos de países: $e";
        isLoading = false;
      });
    }
  }

  void filterCountries(String query) {
    setState(() {
      filteredCountries = LocationData.getCountryNames()
          .where((country) => country.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> filterCities(String query) async {
    if (selectedCountry == null) return;
    String? countryCode = LocationData.getCountryCodeByName(selectedCountry!);
    if (countryCode == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<String> allCities = await LocationData.getCitiesForCountry(countryCode);
      setState(() {
        filteredCities = allCities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar las ciudades: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _verifyCity() async {
    if (selectedCountry == null || selectedCity == null) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String? countryCode = LocationData.getCountryCodeByName(selectedCountry!);
      if (countryCode == null) {
        throw Exception("País no encontrado en nuestros datos");
      }

      List<String> cities = await LocationData.getCitiesForCountry(countryCode);
      if (!cities.contains(selectedCity)) {
        throw Exception("Ciudad no encontrada en nuestros datos para este país");
      }

      // Si llegamos aquí, la ciudad es válida
      print('País seleccionado: $selectedCountry, Ciudad seleccionada: $selectedCity');
      // Aquí puedes navegar a la siguiente pantalla o guardar los datos
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParallaxBackground(
      imagePath: widget.backgroundImagePath,
      child: SafeArea(
        child: Padding(
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
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Text(errorMessage!, style: TextStyle(color: Colors.red))
              else ...[
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
                              filteredCities = [];
                            });
                            filterCities('');
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
                      onChanged: (query) => filterCities(query),
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
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              if (selectedCountry != null && selectedCity != null)
                ElevatedButton(
                  onPressed: isLoading ? null : _verifyCity,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Confirmar ubicación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}