import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/SCR_ONB_01_Welcome.dart';
import 'screens/SCR_ONB_02_BirthInfo.dart';
import 'screens/SCR_01_Home.dart';


void main() {
  initializeDateFormatting('es_ES', null).then((_) => runApp(AstrologiaApp()));
}

class AstrologiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astrología App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Puedes personalizar más el tema aquí
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', 'ES'),
      ],
      home: DevHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DevHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Desarrollo - Seleccionar Pantalla')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Pantalla de Bienvenida'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Welcome(backgroundImagePath: 'assets/welcome.webp')),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Pantalla de Fecha y Hora de Nacimiento'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BirthInfo(
                    backgroundImagePath: 'assets/welcome.webp',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Pantalla main'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeContainer(
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