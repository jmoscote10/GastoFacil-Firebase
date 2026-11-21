import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_container.dart';
import '../widgets/custom_text_field.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();
  final AuthService authService = AuthService();

  bool cargando = false;

  Future<void> registrar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      cargando = true;
    });

    try {
      await authService.registrarUsuario(
        nombreController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      if (mounted) {
        mostrarMensaje(context, 'Cuenta creada correctamente', colorIngreso);
        // Al crear la cuenta la sesión queda iniciada: volvemos al inicio.
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        mostrarMensaje(context, AuthService.mensajeError(error), colorError);
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CustomContainer(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  label: 'Nombre',
                  controller: nombreController,
                  icono: Icons.person,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa tu nombre';
                    }
                    return null;
                  },
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
                    if (valor == null || valor.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  label: 'Confirmar contraseña',
                  controller: confirmarController,
                  icono: Icons.lock_outline,
                  ocultarTexto: true,
                  validator: (valor) {
                    if (valor != passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                cargando
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        texto: 'Registrarme',
                        icono: Icons.person_add,
                        onPressed: registrar,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
