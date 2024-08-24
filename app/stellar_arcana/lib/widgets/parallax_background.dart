import 'package:flutter/material.dart';

class ParallaxBackground extends StatefulWidget {
  final String imagePath;
  final Widget child;

  const ParallaxBackground({
    Key? key,
    required this.imagePath,
    required this.child,
  }) : super(key: key);

  @override
  _ParallaxBackgroundState createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: AnimatedBuilder(
            animation: _offsetAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: _offsetAnimation.value * -300,  // Ajusta este valor según sea necesario
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width + 100,  // Aumenta el tamaño de la imagen
                  height: MediaQuery.of(context).size.height + 100,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}