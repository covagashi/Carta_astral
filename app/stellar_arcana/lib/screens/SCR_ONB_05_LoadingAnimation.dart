import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;


class LoadingAnimation extends StatefulWidget {
  final String profileName;

  LoadingAnimation({Key? key, required this.profileName}) : super(key: key);

  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _textController;
  late AnimationController _starController;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _textAnimation;

  List<Widget> _stars = [];

  @override
  void initState() {
    super.initState();

    // Inicializar animaciones
    _initializeAnimations();

    // Generar estrellas
    _generateStars();

    // Iniciar animaciones
    _startAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _backgroundAnimation = ColorTween(
      begin: Colors.deepPurple,
      end: Colors.black,
    ).animate(_backgroundController);

    _textController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _starController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  void _generateStars() {
    for (int i = 0; i < 100; i++) {
      _stars.add(_createStar());
    }
  }

  void _startAnimations() {
    _backgroundController.forward();
    _textController.forward();
  }

  Widget _createStar() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (_, __) {
        return Positioned(
          left: math.Random().nextDouble() * MediaQuery.of(context).size.width,
          top: math.Random().nextDouble() * MediaQuery.of(context).size.height,
          child: Opacity(
            opacity: math.Random().nextDouble(),
            child: Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            color: _backgroundAnimation.value,
            child: Stack(
              children: [
                ..._stars,
                Center(
                  child: FadeTransition(
                    opacity: _textAnimation,
                    child: Text(
                      "Recorriendo los astros...",
                      style: GoogleFonts.cinzel(
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.white.withOpacity(0.7),
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _textController.dispose();
    _starController.dispose();
    super.dispose();
  }
}