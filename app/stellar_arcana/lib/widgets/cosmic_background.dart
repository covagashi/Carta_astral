import 'package:flutter/material.dart';
import 'dart:math' as math;

class CosmicBackground extends StatefulWidget {
  final Widget child;

  CosmicBackground({required this.child});

  @override
  _CosmicBackgroundState createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentImageIndex;
  late int _nextImageIndex;
  final List<String> _backgroundImages = [
    'assets/fondos/bg1.webp',
    'assets/fondos/bg2.webp',
    'assets/fondos/bg3.webp',
    'assets/fondos/bg4.webp',
    'assets/fondos/bg5.webp',
  ];

  @override
  void initState() {
    super.initState();
    _currentImageIndex = 0;
    _nextImageIndex = 1;
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentImageIndex = _nextImageIndex;
          _nextImageIndex = (_nextImageIndex + 1) % _backgroundImages.length;
          _controller.reset();
        });
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo actual
        Image.asset(
          _backgroundImages[_currentImageIndex],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Imagen de fondo siguiente con opacidad animada
        FadeTransition(
          opacity: _controller,
          child: Image.asset(
            _backgroundImages[_nextImageIndex],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Estrellas animadas
        CustomPaint(
          painter: StarfieldPainter(_controller),
          size: Size.infinite,
        ),
        // Contenido del widget hijo
        widget.child,
      ],
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final Animation<double> animation;

  StarfieldPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = math.sin((animation.value * 2 * math.pi) + random.nextDouble() * math.pi * 2) * 0.5 + 0.5;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) => true;
}