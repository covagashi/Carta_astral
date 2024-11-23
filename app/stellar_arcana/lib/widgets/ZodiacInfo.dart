import 'package:flutter/material.dart';

class ZodiacInfo extends StatelessWidget {
  final String birthDate;
  final String? gender;

  const ZodiacInfo({
    super.key,
    required this.birthDate,
    this.gender = 'F',
  });

  (String sign, String element, String quality, String avatar) _calculateZodiacInfo(String dateStr) {
    final date = DateTime.parse(dateStr);
    final day = date.day;
    final month = date.month;
    String sign;
    String element;
    String quality;

    switch (month) {
      case 1:
        if (day < 20) {
          sign = 'Capricornio';
          element = 'Tierra';
          quality = 'Cardinal';
        } else {
          sign = 'Acuario';
          element = 'Aire';
          quality = 'Fijo';
        }
      case 2:
        if (day < 19) {
          sign = 'Acuario';
          element = 'Aire';
          quality = 'Fijo';
        } else {
          sign = 'Piscis';
          element = 'Agua';
          quality = 'Mutable';
        }
      case 3:
        if (day < 21) {
          sign = 'Piscis';
          element = 'Agua';
          quality = 'Mutable';
        } else {
          sign = 'Aries';
          element = 'Fuego';
          quality = 'Cardinal';
        }
      case 4:
        if (day < 20) {
          sign = 'Aries';
          element = 'Fuego';
          quality = 'Cardinal';
        } else {
          sign = 'Tauro';
          element = 'Tierra';
          quality = 'Fijo';
        }
      case 5:
        if (day < 21) {
          sign = 'Tauro';
          element = 'Tierra';
          quality = 'Fijo';
        } else {
          sign = 'Géminis';
          element = 'Aire';
          quality = 'Mutable';
        }
      case 6:
        if (day < 21) {
          sign = 'Géminis';
          element = 'Aire';
          quality = 'Mutable';
        } else {
          sign = 'Cáncer';
          element = 'Agua';
          quality = 'Cardinal';
        }
      case 7:
        if (day < 23) {
          sign = 'Cáncer';
          element = 'Agua';
          quality = 'Cardinal';
        } else {
          sign = 'Leo';
          element = 'Fuego';
          quality = 'Fijo';
        }
      case 8:
        if (day < 23) {
          sign = 'Leo';
          element = 'Fuego';
          quality = 'Fijo';
        } else {
          sign = 'Virgo';
          element = 'Tierra';
          quality = 'Mutable';
        }
      case 9:
        if (day < 23) {
          sign = 'Virgo';
          element = 'Tierra';
          quality = 'Mutable';
        } else {
          sign = 'Libra';
          element = 'Aire';
          quality = 'Cardinal';
        }
      case 10:
        if (day < 23) {
          sign = 'Libra';
          element = 'Aire';
          quality = 'Cardinal';
        } else {
          sign = 'Escorpio';
          element = 'Agua';
          quality = 'Fijo';
        }
      case 11:
        if (day < 22) {
          sign = 'Escorpio';
          element = 'Agua';
          quality = 'Fijo';
        } else {
          sign = 'Sagitario';
          element = 'Fuego';
          quality = 'Mutable';
        }
      case 12:
        if (day < 22) {
          sign = 'Sagitario';
          element = 'Fuego';
          quality = 'Mutable';
        } else {
          sign = 'Capricornio';
          element = 'Tierra';
          quality = 'Cardinal';
        }
      default:
        sign = 'Error';
        element = 'Error';
        quality = 'Error';
    }

    // Generate avatar filename
    final signForFile = _getSignForFilename(sign);
    final avatar = '$signForFile${gender?.toUpperCase() ?? 'F'}.webp';

    return (sign, element, quality, avatar);
  }

  String _getSignForFilename(String sign) {
    final signMap = {
      'Aries': 'aries',
      'Tauro': 'taurus',
      'Géminis': 'geminis',
      'Cáncer': 'cancer',
      'Leo': 'leo',
      'Virgo': 'virgo',
      'Libra': 'libra',
      'Escorpio': 'scorpio',
      'Sagitario': 'sagitario',
      'Capricornio': 'capricorn',
      'Acuario': 'aquarius',
      'Piscis': 'piscis',
    };
    return signMap[sign] ?? 'aries';
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

  String getAvatarFilename() {
    final (_, _, _, avatar) = _calculateZodiacInfo(birthDate);
    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    final (sign, element, quality, _) = _calculateZodiacInfo(birthDate);
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