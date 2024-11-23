import 'package:flutter/material.dart';
import '../widgets/cosmic_background.dart';
import '../services/json_profile_storage_service.dart';
import '../widgets/ZodiacInfo.dart';


class Scr01Perfil extends StatefulWidget {
  final String profileName;
  final Function(String)? onAvatarChanged;

  const Scr01Perfil({
    super.key,
    required this.profileName,
    this.onAvatarChanged,
  });

  @override
  State<Scr01Perfil> createState() => _Scr01PerfilState();
}

class _Scr01PerfilState extends State<Scr01Perfil> {
  Map<String, dynamic>? profileData;
  String? currentAvatar;
  bool isLoading = true;
  final List<String> availableAvatars = [
    'aquariusF.webp', 'aquariusM.webp',
    'ariesF.webp', 'ariesM.webp',
    'cancerF.webp', 'cancerM.webp',
    'capricornF.webp', 'capricornM.webp',
    'geminisF.webp', 'geminisM.webp',
    'leoF.webp', 'leoM.webp',
    'libraF.webp', 'libraM.webp',
    'piscisF.webp', 'piscisM.webp',
    'sagitarioF.webp', 'sagitarioM.webp',
    'scorpioF.webp', 'scorpioM.webp',
    'taurusF.webp', 'taurusM.webp',
    'virgoF.webp', 'virgoM.webp'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await JsonProfileStorageService.readProfileData(widget.profileName);
      if (!mounted) return;

      final String defaultAvatar = ZodiacInfo(
          birthDate: data['birthDate'],
          gender: data['gender'] ?? 'F'
      ).getAvatarFilename();

      setState(() {
        profileData = data;
        currentAvatar = data['selectedAvatar'] ?? defaultAvatar;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos del perfil: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAvatar(String newAvatar) async {
    try {
      await JsonProfileStorageService.updateAvatar(widget.profileName, newAvatar);
      if (!mounted) return;

      setState(() {
        currentAvatar = newAvatar;
      });
      widget.onAvatarChanged?.call(newAvatar);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving avatar: $e');
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  Widget _buildProfileAvatar() {
    if (currentAvatar == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withOpacity(0.5),
                Colors.purple.withOpacity(0.5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/avatar/$currentAvatar'),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.black26.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.indigoAccent,
                width: 0.7,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, size: 16),
              color: Colors.white,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              onPressed: () => _showAvatarSelector(),
            ),
          ),
        ),
      ],
    );
  }

  void _showAvatarSelector() {
    if (currentAvatar == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.indigoAccent.withOpacity(0.5),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: availableAvatars.length,
                itemBuilder: (context, index) {
                  final avatarName = availableAvatars[index];
                  final isSelected = currentAvatar == avatarName;

                  return GestureDetector(
                    onTap: () => _saveAvatar(avatarName),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/avatar/$avatarName'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tu Esencia Cósmica',
          style: TextStyle(color: Colors.white),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: CosmicBackground(
        child: SafeArea(
          child: isLoading
              ? _buildLoadingState()
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileAvatar(),
                const SizedBox(height: 20),
                _buildProfileInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    if (profileData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withOpacity(0.7),
                Colors.purple.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text(
                widget.profileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Fecha de\nnacimiento:',
                _formatDate(profileData?['birthDate']),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Hora de\nnacimiento:',
                '${profileData?['birthTime'] ?? 'No disponible'}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Lugar de\nnacimiento:',
                '${profileData?['city']}, ${profileData?['country']}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (profileData?['birthDate'] != null)
          ZodiacInfo(birthDate: profileData!['birthDate']),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No disponible';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}