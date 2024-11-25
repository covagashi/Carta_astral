import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/SCR_ONB_01_Welcome.dart';
import 'screens/SCR_ONB_02_BirthInfo.dart';
import 'screens/SCR_01_Home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/remote_config_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final remoteConfig = RemoteConfigService();
  await remoteConfig.initialize();

  runApp(const AstrologiaApp());
}

class AstrologiaApp extends StatelessWidget {
  const AstrologiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astrología App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Puedes personalizar más el tema aquí
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
              child: const Text('Pantalla main'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeContainer(
                    profileName: 'Estelar',
                  ),
                ),
              ),
            ),


            // Añade más botones aquí para otras pantallas que quieras probar
          ],
        ),
      ),
    );
  }
}