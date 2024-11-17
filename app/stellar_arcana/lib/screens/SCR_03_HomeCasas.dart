import 'package:flutter/material.dart';
import '../widgets/astrological_section_widget.dart';

class SCR_03_HomeCasas extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const SCR_03_HomeCasas({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return AstrologicalSectionWidget(
      chartData: profileData['chartData'],
      titleKeywords: const ['Casa'],
      sectionType: 'casas',
    );
  }
}