import 'package:flutter/material.dart';
import '../widgets/astrological_section_widget.dart';

class SCR_04_HomeAspectos extends StatelessWidget {
  final Map<String, dynamic> profileData;

  SCR_04_HomeAspectos({Key? key, required this.profileData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AstrologicalSectionWidget(
      chartData: profileData['chartData'],
      titleKeywords: ['Aspectos', 'Trigono', 'Cuadratura', 'Oposición', 'Sextil', 'Conjunción'],
      sectionType: 'aspectos',
    );
  }
}
