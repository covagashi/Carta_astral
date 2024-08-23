import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Stellar Arcana'),
            ),
            body: Center(
                child: Text('Bienvenido a Stellar Arcana'),
            ),
        );

    }
}