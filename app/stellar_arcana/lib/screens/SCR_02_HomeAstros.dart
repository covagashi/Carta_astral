import 'package:flutter/material.dart';
import '../widgets/astrological_section_widget.dart';

class SCR_02_HomeAstros extends StatelessWidget {
  final Map<String, dynamic> profileData;

  SCR_02_HomeAstros({Key? key, required this.profileData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AstrologicalSectionWidget(
      chartData: profileData['chartData'],
      titleKeywords: ['Sol', 'Luna', 'Mercurio', 'Venus', 'Marte', 'Júpiter', 'Saturno', 'Urano', 'Neptuno', 'Plutón', 'Lilith'],
      sectionType: 'planetas',
    );
  }
}