import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_container.dart';
import '../widgets/custom_text_field.dart';
import 'register_user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  bool cargando = false;

  Future<void> iniciarSesion() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      cargando = true;
    });

    try {
      await authService.iniciarSesion(
        emailController.text.trim(),
        passwordController.text,
      );
      // Si todo sale bien, ControlSesion abre el inicio automáticamente.
    } catch (error) {
      if (mounted) {
        mostrarMensaje(context, AuthService.mensajeError(error), colorError);
      }
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Logo de GastoFácil (ya incluye el nombre de la app).
              Image.asset(
                rutaLogo,
                height: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_wallet,
                  size: 70,
                  color: colorVerde,
                ),
              ),
              const Text(
                'Controla tus ingresos y gastos',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              CustomContainer(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: 'Correo electrónico',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        icono: Icons.email,
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!valor.contains('@') || !valor.contains('.')) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        label: 'Contraseña',
                        controller: passwordController,
                        icono: Icons.lock,
                        ocultarTexto: true,
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      cargando
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              texto: 'Iniciar sesión',
                              icono: Icons.login,
                              onPressed: iniciarSesion,
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterUserScreen(),
                    ),
                  );
                },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
