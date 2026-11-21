import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Conecta la aplicación con el proyecto de Firebase "gastofacilact".
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const GastoFacilApp());
}

class GastoFacilApp extends StatelessWidget {
  const GastoFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: nombreApp,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: colorPrincipal,
        scaffoldBackgroundColor: colorFondo,
        colorScheme: ColorScheme.fromSeed(seedColor: colorPrincipal),
      ),
      home: const ControlSesion(),
    );
  }
}

// Decide qué pantalla mostrar según el estado de la sesión.
// Firebase guarda la sesión, por eso al volver a abrir la app
// el usuario sigue dentro hasta que cierre sesión.
class ControlSesion extends StatelessWidget {
  const ControlSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Sin sesión: no puede entrar a las pantallas privadas.
        return const LoginScreen();
      },
    );
  }
}
