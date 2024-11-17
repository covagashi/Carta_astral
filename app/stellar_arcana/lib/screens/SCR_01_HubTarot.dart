import 'package:flutter/material.dart';
import '../widgets/cosmic_background.dart';

class SCR_01_HubTarot extends StatelessWidget {
  const SCR_01_HubTarot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hub de Tarot'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16.0),
            childAspectRatio: 1.0,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
            children: [
              _buildTarotOption(context, 'Tirada Diaria', Icons.calendar_today),
              _buildTarotOption(context, 'Tirada de 3 Cartas', Icons.filter_3),
              _buildTarotOption(context, 'Tirada Celta', Icons.stars),
              _buildTarotOption(context, 'Interpretaciones', Icons.book),
              // Añade más opciones según sea necesario
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarotOption(BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () {
        // Implementar navegación a la pantalla correspondiente
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}