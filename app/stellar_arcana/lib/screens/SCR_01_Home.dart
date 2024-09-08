import 'package:flutter/material.dart';
import '../widgets/cosmic_background.dart';
import '../services/json_profile_storage_service.dart';
import '../widgets/custom_app_bar.dart';
import 'SCR_05_HomeContent.dart';

class HomeContainer extends StatefulWidget {
  final String profileName;

  HomeContainer({Key? key, required this.profileName}) : super(key: key);

  @override
  _HomeContainerState createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  String _avatarPath = 'assets/avatar/ariesF.webp'; // Default avatar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        // Aquí deberías determinar el avatar correcto basado en los datos del perfil
        // _avatarPath = _determineAvatarPath(data['sunSign'], data['gender']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        profileName: widget.profileName,
        avatarPath: _avatarPath,
      ),
      body: CosmicBackground(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Resumen'),
                Tab(text: 'Astros'),
                Tab(text: 'Casas'),
                Tab(text: 'Aspectos'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
            ),
            Expanded(
              child: _buildTabBarView(),
            ),
            // Cuadro de publicidad
            Container(
              height: 60,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Text(
                  'Espacio para publicidad',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.white)));
    } else if (_profileData != null) {
      return TabBarView(
        controller: _tabController,
        children: [
          HomeContent(chartData: _profileData!['chartData'], sectionType: 'resumen'),
          HomeContent(chartData: _profileData!['chartData'], sectionType: 'planetas'),
          HomeContent(chartData: _profileData!['chartData'], sectionType: 'casas'),
          HomeContent(chartData: _profileData!['chartData'], sectionType: 'aspectos'),
        ],
      );
    } else {
      return Center(child: Text("No se encontraron datos del perfil", style: TextStyle(color: Colors.white)));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}