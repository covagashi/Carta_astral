import 'package:flutter/material.dart';
import 'dart:convert';
import '../widgets/astrological_section_widget.dart';

class HomeContent extends StatelessWidget {
  final Map<String, dynamic> chartData;
  final String sectionType;
  final String base64Image;

  HomeContent({
    Key? key,
    required this.chartData,
    required this.sectionType,
    required this.base64Image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> titleKeywords;
    switch (sectionType) {
      case 'resumen':
        titleKeywords = ['Prólogo', 'Cualidades', 'Elementos', 'Polaridad'];
        break;
      case 'planetas':
        titleKeywords = ['Sol', 'Luna', 'Mercurio', 'Venus', 'Marte', 'Júpiter', 'Saturno', 'Urano', 'Neptuno', 'Plutón', 'Lilith'];
        break;
      case 'casas':
        titleKeywords = ['Casa'];
        break;
      case 'aspectos':
        titleKeywords = ['Aspectos', 'Trigono', 'Cuadratura', 'Oposición', 'Sextil', 'Conjunción', 'Cuadrantes', 'Ascendente'];
        break;
      default:
        titleKeywords = [];
    }

    return Column(
      children: [
        // Mostrar la imagen solo en la sección de resumen
        if (sectionType == 'resumen') _buildImageWidget(),
        // Mostrar el contenido astrológico
        Expanded(
          child: AstrologicalSectionWidget(
            chartData: chartData,
            titleKeywords: titleKeywords,
            sectionType: sectionType,
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (base64Image.isEmpty) {
      return SizedBox.shrink(); // No mostrar nada si no hay imagen
    }

    try {
      final imageBytes = base64Decode(base64Image);
      return Stack(
        alignment: Alignment.center,
        children: [
          // Fondo con gradiente circular
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.7,
                colors: [Colors.white, Colors.blue.withOpacity(0)],
                stops: [0.5, 1.0],
              ),
            ),
          ),
          // Carta astral
          Image.memory(
            imageBytes,
            fit: BoxFit.contain,
            width: double.infinity,
            height: 300,
          ),
        ],
      );
    } catch (e) {
      print('Error al decodificar la imagen: $e');
      return SizedBox.shrink(); // No mostrar nada en caso de error
    }
  }
}