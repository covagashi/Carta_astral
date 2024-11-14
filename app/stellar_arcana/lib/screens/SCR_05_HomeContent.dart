import 'package:flutter/material.dart';
import 'dart:convert';

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
    Map<String, String> sectionSymbols = {
      'Sol': '\u2609',        // ☉
      'Luna': '\u263D',       // ☽
      'Mercurio': '\u263F',   // ☿
      'Venus': '\u2640',      // ♀
      'Marte': '\u2642',      // ♂
      'Júpiter': '\u2643',    // ♃
      'Saturno': '\u2644',    // ♄
      'Urano': '\u2645',      // ♅
      'Neptuno': '\u2646',    // ♆
      'Plutón': '\u2647',     // ♇
      'Pluton': '\u2647',     // ♇
      'Lilith': '\u26B8',     // ⚸
    };

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
        titleKeywords = ['Aspectos', 'Trigono', 'Cuadratura', 'Oposición', 'Sextil', 'Conjunción'];
        break;
      default:
        titleKeywords = [];
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (sectionType == 'resumen') _buildImageWidget(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: _buildSections(titleKeywords, sectionSymbols),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    if (base64Image.isEmpty) {
      return SizedBox.shrink();
    }

    try {
      final imageBytes = base64Decode(base64Image);
      final screenWidth = MediaQuery.of(context).size.width;
      final imageSize = screenWidth * 0.85;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                ClipOval(
                  child: Image.memory(
                    imageBytes,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error al decodificar la imagen: $e');
      return SizedBox.shrink();
    }
  }

  List<Widget> _buildSections(List<String> titleKeywords, Map<String, String> sectionSymbols) {
    if (chartData['content'] == null) {
      return [Center(child: Text('No hay datos disponibles', style: TextStyle(color: Colors.white)))];
    }

    final List<dynamic> sections = chartData['content'];
    final filteredSections = sections.where((section) {
      final title = section['title'].toString().toLowerCase();
      return titleKeywords.any((keyword) =>
      title.contains(keyword.toLowerCase()) &&
          (sectionType != 'planetas' || !title.contains('casa')));
    }).toList();

    return filteredSections.map<Widget>((section) {
      String? sectionSymbol;
      for (var keyword in sectionSymbols.keys) {
        if (section['title'].toString().toLowerCase().contains(keyword.toLowerCase())) {
          sectionSymbol = sectionSymbols[keyword];
          break;
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _ExpandableSection(
          title: section['title'],
          symbol: sectionSymbol,
          content: section['paragraphs'],
        ),
      );
    }).toList();
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final String? symbol;
  final List<dynamic> content;

  _ExpandableSection({
    required this.title,
    this.symbol,
    required this.content,
  });

  @override
  _ExpandableSectionState createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.indigoAccent.withOpacity(0.75),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                if (widget.symbol != null) ...[
                  Text(
                    widget.symbol!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0),
          secondChild: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.content.map<Widget>((paragraph) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    paragraph.toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 300),
        ),
      ],
    );
  }
}