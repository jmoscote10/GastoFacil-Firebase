import 'package:flutter/material.dart';

import '../models/movimiento_model.dart';
import '../services/auth_service.dart';
import '../services/movimiento_service.dart';
import '../utils/constants.dart';
import '../widgets/movimiento_form.dart';

class RegistroMovimientoScreen extends StatelessWidget {
  const RegistroMovimientoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MovimientoService servicio = MovimientoService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar movimiento'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: MovimientoForm(
        textoBoton: 'Guardar movimiento',
        onGuardar: (MovimientoModel movimiento) async {
          try {
            // Crea el documento en la colección "movements" de Firestore.
            await servicio.agregarMovimiento(movimiento);

            if (context.mounted) {
              mostrarMensaje(
                context,
                'Movimiento guardado correctamente',
                colorIngreso,
              );
              Navigator.pop(context);
            }
          } catch (error) {
            if (context.mounted) {
              mostrarMensaje(
                context,
                AuthService.mensajeError(error),
                colorError,
              );
            }
          }
        },
      ),
    );
  }
}
