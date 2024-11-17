import 'package:flutter/material.dart';

class ZodiacInfo extends StatelessWidget {
  final String birthDate;

  const ZodiacInfo({super.key, required this.birthDate});

  (String sign, String element, String quality) _calculateZodiacSign(String dateStr) {
    final date = DateTime.parse(dateStr);
    final day = date.day;
    final month = date.month;

    // Tupla de (Signo, Elemento, Cualidad)
    switch (month) {
      case 1:
        return day < 20
            ? ('Capricornio', 'Tierra', 'Cardinal')
            : ('Acuario', 'Aire', 'Fijo');
      case 2:
        return day < 19
            ? ('Acuario', 'Aire', 'Fijo')
            : ('Piscis', 'Agua', 'Mutable');
      case 3:
        return day < 21
            ? ('Piscis', 'Agua', 'Mutable')
            : ('Aries', 'Fuego', 'Cardinal');
      case 4:
        return day < 20
            ? ('Aries', 'Fuego', 'Cardinal')
            : ('Tauro', 'Tierra', 'Fijo');
      case 5:
        return day < 21
            ? ('Tauro', 'Tierra', 'Fijo')
            : ('Géminis', 'Aire', 'Mutable');
      case 6:
        return day < 21
            ? ('Géminis', 'Aire', 'Mutable')
            : ('Cáncer', 'Agua', 'Cardinal');
      case 7:
        return day < 23
            ? ('Cáncer', 'Agua', 'Cardinal')
            : ('Leo', 'Fuego', 'Fijo');
      case 8:
        return day < 23
            ? ('Leo', 'Fuego', 'Fijo')
            : ('Virgo', 'Tierra', 'Mutable');
      case 9:
        return day < 23
            ? ('Virgo', 'Tierra', 'Mutable')
            : ('Libra', 'Aire', 'Cardinal');
      case 10:
        return day < 23
            ? ('Libra', 'Aire', 'Cardinal')
            : ('Escorpio', 'Agua', 'Fijo');
      case 11:
        return day < 22
            ? ('Escorpio', 'Agua', 'Fijo')
            : ('Sagitario', 'Fuego', 'Mutable');
      case 12:
        return day < 22
            ? ('Sagitario', 'Fuego', 'Mutable')
            : ('Capricornio', 'Tierra', 'Cardinal');
      default:
        return ('Error', 'Error', 'Error');
    }
  }

  String _getZodiacSymbol(String sign) {
    final Map<String, String> symbols = {
      'Aries': '♈',
      'Tauro': '♉',
      'Géminis': '♊',
      'Cáncer': '♋',
      'Leo': '♌',
      'Virgo': '♍',
      'Libra': '♎',
      'Escorpio': '♏',
      'Sagitario': '♐',
      'Capricornio': '♑',
      'Acuario': '♒',
      'Piscis': '♓',
    };
    return symbols[sign] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final (sign, element, quality) = _calculateZodiacSign(birthDate);
    final symbol = _getZodiacSymbol(sign);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withOpacity(0.7),
            Colors.purple.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                symbol,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                sign,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip('Elemento', element),
              _buildInfoChip('Cualidad', quality),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}