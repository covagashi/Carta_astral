import 'package:flutter/material.dart';
import '../widgets/astrological_section_widget.dart';

class SCR_01_HomeResumen extends StatelessWidget {
  final Map<String, dynamic> profileData;

  SCR_01_HomeResumen({Key? key, required this.profileData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AstrologicalSectionWidget(
      chartData: profileData['chartData'],
      titleKeywords: ['Prólogo', 'Cualidades', 'Elementos', 'Polaridad', 'Cuadrantes', 'Ascendente'],
      sectionType: 'resumen',
    );
  }
}