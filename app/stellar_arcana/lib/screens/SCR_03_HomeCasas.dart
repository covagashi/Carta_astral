import 'package:flutter/material.dart';
import '../widgets/astrological_section_widget.dart';

class SCR_03_HomeCasas extends StatelessWidget {
  final Map<String, dynamic> profileData;

  SCR_03_HomeCasas({Key? key, required this.profileData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AstrologicalSectionWidget(
      chartData: profileData['chartData'],
      titleKeywords: ['Casa'],
      sectionType: 'casas',
    );
  }
}