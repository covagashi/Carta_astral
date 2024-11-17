import 'package:flutter/material.dart';
import '../widgets/astrological_section_widget.dart';

class SCR_02_HomeAstros extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const SCR_02_HomeAstros({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return AstrologicalSectionWidget(
      chartData: profileData['chartData'],
      titleKeywords: const ['Sol', 'Luna', 'Mercurio', 'Venus', 'Marte', 'Júpiter', 'Saturno', 'Urano', 'Neptuno', 'Plutón', 'Lilith'],
      sectionType: 'planetas',
    );
  }
}