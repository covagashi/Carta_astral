import 'package:flutter/material.dart';
import '../widgets/astrological_section_widget.dart';

class SCR_04_HomeAspectos extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const SCR_04_HomeAspectos({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return AstrologicalSectionWidget(
      chartData: profileData['chartData'],
      titleKeywords: const ['Aspectos', 'Trigono', 'Cuadratura', 'Oposición', 'Sextil', 'Conjunción'],
      sectionType: 'aspectos',
    );
  }
}
