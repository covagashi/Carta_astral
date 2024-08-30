import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/parallax_background.dart';
import '../services/json_profile_storage_service.dart';
import 'SCR_01_HomeResumen.dart';
import 'SCR_02_HomeAstros.dart';
import 'SCR_03_HomeCasas.dart';
import 'SCR_04_HomeAspectos.dart';

class Home extends StatefulWidget {
  final String profileName;

  Home({Key? key, required this.profileName}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic>? _profileData;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      print("Intentando cargar datos para el perfil: ${widget.profileName}");
      final data = await JsonProfileStorageService.readProfileData(widget.profileName);
      print("Datos cargados: $data");
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
      print("Datos del perfil cargados con éxito");
    } catch (e) {
      print("Error al cargar los datos del perfil: $e");
      setState(() {
        _errorMessage = "Error al cargar los datos: $e";
        _isLoading = false;
      });
    }
  }

  Widget _buildNavButton(String title, int index) {
    return TextButton(
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.6),
          fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxBackground(
        imagePath: 'assets/splash2.webp',
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavButton('Resumen', 0),
                    _buildNavButton('Astros', 1),
                    _buildNavButton('Casas', 2),
                    _buildNavButton('Aspectos', 3),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.white)))
                    : _profileData != null
                    ? IndexedStack(
                  index: _currentIndex,
                  children: [
                    SCR_01_HomeResumen(profileData: _profileData!),
                    SCR_02_HomeAstros(profileData: _profileData!),
                    SCR_03_HomeCasas(profileData: _profileData!),
                    SCR_04_HomeAspectos(profileData: _profileData!),
                  ],
                )
                    : Center(child: Text("No se encontraron datos del perfil", style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}