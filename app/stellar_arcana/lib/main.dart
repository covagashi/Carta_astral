import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/SCR_ONB_01_Welcome.dart';
import 'screens/SCR_ONB_02_BirthInfo.dart';
import 'screens/SCR_01_Home.dart';
import 'screens/SCR_01_AstrosAhora.dart';

void main() {
  initializeDateFormatting('es_ES', null).then((_) => runApp(const AstrologiaApp()));
}

class AstrologiaApp extends StatelessWidget {
  const AstrologiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astrología App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      home: const DevHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DevHomeScreen extends StatelessWidget {
  const DevHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Desarrollo - Seleccionar Pantalla')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Pantalla de Bienvenida'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Welcome(backgroundImagePath: 'assets/welcome.webp')),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Pantalla de Fecha y Hora de Nacimiento'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BirthInfo(
                    backgroundImagePath: 'assets/welcome.webp',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Pantalla Principal'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeContainer(
                    profileName: 'Estelar',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Astros Ahora'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AstrosAhora(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}