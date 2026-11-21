import 'package:flutter/material.dart';

import '../models/movimiento_model.dart';
import '../services/auth_service.dart';
import '../services/movimiento_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_container.dart';
import 'editar_movimiento_screen.dart';

class DetalleMovimientoScreen extends StatefulWidget {
  final String movimientoId;

  const DetalleMovimientoScreen({super.key, required this.movimientoId});

  @override
  State<DetalleMovimientoScreen> createState() =>
      _DetalleMovimientoScreenState();
}

class _DetalleMovimientoScreenState extends State<DetalleMovimientoScreen> {
  final MovimientoService servicio = MovimientoService();
  late Stream<MovimientoModel?> streamMovimiento;
  bool eliminando = false;

  @override
  void initState() {
    super.initState();
    // Escucha el documento: si se edita, el detalle se actualiza solo.
    streamMovimiento = servicio.obtenerMovimiento(widget.movimientoId);
  }

  Future<void> eliminar(MovimientoModel movimiento) async {
    // Confirmación antes de eliminar.
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: Text(
          '¿Seguro que deseas eliminar "${movimiento.descripcion}"?\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: colorGasto)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      eliminando = true;
    });

    try {
      await servicio.eliminarMovimiento(movimiento.id);
      if (mounted) {
        mostrarMensaje(context, 'Movimiento eliminado', colorIngreso);
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        mostrarMensaje(context, AuthService.mensajeError(error), colorError);
        setState(() {
          eliminando = false;
        });
      }
    }
  }

  Widget fila(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(titulo, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del movimiento'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<MovimientoModel?>(
        stream: streamMovimiento,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(AuthService.mensajeError(snapshot.error!)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          MovimientoModel? movimiento = snapshot.data;

          if (movimiento == null) {
            return const Center(child: Text('El movimiento ya no existe'));
          }

          bool esIngreso = movimiento.tipo == 'Ingreso';
          Color color = esIngreso ? colorIngreso : colorGasto;
          String signo = esIngreso ? '+' : '-';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomContainer(
                color: color,
                child: Column(
                  children: [
                    Text(
                      movimiento.tipo,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$signo \$ ${formatearMonto(movimiento.valor)} COP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              CustomContainer(
                child: Column(
                  children: [
                    fila('Descripción', movimiento.descripcion),
                    fila('Categoría', movimiento.categoriaNombre),
                    fila('Fecha', formatearFecha(movimiento.fechaMovimiento)),
                    fila(
                      'Registrado',
                      movimiento.fechaCreacion == null
                          ? '-'
                          : formatearFecha(movimiento.fechaCreacion!),
                    ),
                    fila(
                      'Actualizado',
                      movimiento.fechaActualizacion == null
                          ? '-'
                          : formatearFecha(movimiento.fechaActualizacion!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              CustomButton(
                texto: 'Editar',
                icono: Icons.edit,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditarMovimientoScreen(movimiento: movimiento),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              eliminando
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => eliminar(movimiento),
                        icon: const Icon(Icons.delete, color: colorGasto),
                        label: const Text(
                          'Eliminar',
                          style: TextStyle(
                            color: colorGasto,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: colorGasto),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
