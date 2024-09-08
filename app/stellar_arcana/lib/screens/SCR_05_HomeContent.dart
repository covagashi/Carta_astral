import 'package:flutter/material.dart';
import '../widgets/astrological_section_widget.dart';

class HomeContent extends StatelessWidget {
  final Map<String, dynamic> chartData;
  final String sectionType;

  HomeContent({Key? key, required this.chartData, required this.sectionType}) : super(key: key);

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

    return AstrologicalSectionWidget(
      chartData: chartData,
      titleKeywords: titleKeywords,
      sectionType: sectionType,
    );
  }
}
