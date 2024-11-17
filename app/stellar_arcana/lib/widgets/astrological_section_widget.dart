import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class AstrologicalSectionWidget extends StatelessWidget {
  final dynamic chartData;
  final List<String> titleKeywords;
  final String sectionType;

  const AstrologicalSectionWidget({
    super.key,
    required this.chartData,
    required this.titleKeywords,
    required this.sectionType,
  });

  bool _titleMatchesKeywords(String title) {
    switch (sectionType) {
      case 'aspectos':
        return titleKeywords.any((keyword) => title.toLowerCase().contains(keyword.toLowerCase()));
      case 'casas':
        return title.toLowerCase().contains('casa');
      case 'planetas':
        return titleKeywords.any((keyword) => title.toLowerCase().startsWith(keyword.toLowerCase())) &&
            !title.toLowerCase().contains('casa') &&
            !_isAspectTitle(title);
      case 'resumen':
      default:
        return titleKeywords.any((keyword) => title.toLowerCase().contains(keyword.toLowerCase())) &&
            !_isAspectTitle(title);
    }
  }

  bool _isAspectTitle(String title) {
    final aspectKeywords = ['Aspectos', 'Trigono', 'Cuadratura', 'Oposición', 'Sextil', 'Conjunción'];
    return aspectKeywords.any((keyword) => title.toLowerCase().contains(keyword.toLowerCase()));
  }


  String _getAsciiSymbol(String title) {
    // Mapa de símbolos usando códigos Unicode
    final Map<String, String> symbols = {
      // Planetas
      'Sol': '\u2609',      // ☉
      'Luna': '\u263D',     // ☽
      'Mercurio': '\u263F', // ☿
      'Venus': '\u2640',    // ♀
      'Marte': '\u2642',    // ♂
      'Júpiter': '\u2643',  // ♃
      'Saturno': '\u2644',  // ♄
      'Urano': '\u2645',    // ♅
      'Neptuno': '\u2646',  // ♆
      'Plutón': '\u2647',   // ♇
      'Pluton': '\u2647',   // ♇

      // Signos zodiacales
      'Aries': '\u2648',    // ♈
      'Tauro': '\u2649',    // ♉
      'Géminis': '\u264A',  // ♊
      'Cáncer': '\u264B',   // ♋
      'Leo': '\u264C',      // ♌
      'Virgo': '\u264D',    // ♍
      'Libra': '\u264E',    // ♎
      'Escorpio': '\u264F', // ♏
      'Sagitario': '\u2650',// ♐
      'Capricornio': '\u2651', // ♑
      'Acuario': '\u2652',  // ♒
      'Piscis': '\u2653',   // ♓

      // Aspectos
      'Conjunción': '\u260C',  // ☌
      'Oposición': '\u260D',   // ☍
      'Trígono': '\u25B3',     // △
      'Cuadratura': '\u25A1',  // □
      'Sextil': '\u26B9',      // ⚹

      // Otros
      'Lilith': '\u26B8',      // ⚸
    };

    for (var key in symbols.keys) {
      if (title.contains(key)) {
        return symbols[key]!;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? data;
    if (chartData is String) {
      try {
        data = json.decode(chartData);
      } catch (e) {
        print('Error al decodificar chartData: $e');
      }
    } else if (chartData is Map<String, dynamic>) {
      data = chartData;
    }

    if (data == null || !data.containsKey('content')) {
      return const Center(child: Text('No hay datos disponibles', style: TextStyle(color: Colors.white)));
    }

    final List<dynamic> sections = data['content'] as List<dynamic>;
    List<dynamic> filteredSections;

    if (sectionType == 'aspectos') {
      filteredSections = sections.where((section) => _isAspectTitle(section['title'])).toList();
    } else {
      filteredSections = sections.where((section) => _titleMatchesKeywords(section['title'])).toList();
    }

    if (filteredSections.isEmpty) {
      return const Center(child: Text('No se encontraron secciones relevantes', style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: filteredSections.length,
      itemBuilder: (context, index) {
        final section = filteredSections[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black12.withOpacity(0.7), Colors.indigo.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      _getAsciiSymbol(section['title']),
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        section['title'],
                        style: GoogleFonts.cinzel(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const SizedBox.shrink(), // Elimina el icono de expansión
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 16,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (section['paragraphs'] as List<dynamic>).map<Widget>((paragraph) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            paragraph.toString(),
                            style: GoogleFonts.comfortaa(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                        )
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}