import 'package:flutter/material.dart';
import '../widgets/cosmic_background.dart';
import '../services/json_profile_storage_service.dart';
import '../widgets/custom_app_bar.dart';
import 'SCR_05_HomeContent.dart';

class HomeContainer extends StatefulWidget {
  final String profileName;

  const HomeContainer({super.key, required this.profileName});

  @override
  _HomeContainerState createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profileData;
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  final String _avatarPath = 'assets/avatar/ariesF.webp'; // Default avatar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await JsonProfileStorageService.readProfileData(widget.profileName);
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error al cargar los datos: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        profileName: widget.profileName,
        avatarPath: _avatarPath,
      ),
      body: CosmicBackground(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
            TabBar(
              controller: _tabController,
              tabs: const [
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
            Container(
              height: 60,
              color: Colors.black.withOpacity(0.5),
              child: const Center(
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
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)));
    } else if (_profileData != null) {
      // Verificar si chartData y chartImage existen en _profileData
      final chartData = _profileData!['chartData'];
      final base64Image = _profileData!['chartImage'] as String? ?? '';
      print("Longitud de base64Image en _buildTabBarView: ${base64Image.length}");

      if (chartData == null) {
        return const Center(child: Text("Datos de la carta no disponibles", style: TextStyle(color: Colors.white)));
      }

      return TabBarView(
        controller: _tabController,
        children: [
          HomeContent(chartData: chartData, sectionType: 'resumen', base64Image: base64Image),
          HomeContent(chartData: chartData, sectionType: 'planetas', base64Image: base64Image),
          HomeContent(chartData: chartData, sectionType: 'casas', base64Image: base64Image),
          HomeContent(chartData: chartData, sectionType: 'aspectos', base64Image: base64Image),
        ],
      );
    } else {
      return const Center(child: Text("No se encontraron datos del perfil", style: TextStyle(color: Colors.white)));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}