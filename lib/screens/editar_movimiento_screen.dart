import 'package:flutter/material.dart';

import '../models/movimiento_model.dart';
import '../services/auth_service.dart';
import '../services/movimiento_service.dart';
import '../utils/constants.dart';
import '../widgets/movimiento_form.dart';

class EditarMovimientoScreen extends StatelessWidget {
  final MovimientoModel movimiento;

  const EditarMovimientoScreen({super.key, required this.movimiento});

  @override
  Widget build(BuildContext context) {
    final MovimientoService servicio = MovimientoService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar movimiento'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: MovimientoForm(
        movimiento: movimiento,
        textoBoton: 'Actualizar movimiento',
        onGuardar: (MovimientoModel movimientoEditado) async {
          try {
            // Actualiza el documento existente en Firestore.
            await servicio.actualizarMovimiento(movimientoEditado);

            if (context.mounted) {
              mostrarMensaje(
                context,
                'Movimiento actualizado correctamente',
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
