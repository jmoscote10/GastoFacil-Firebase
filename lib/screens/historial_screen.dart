import 'package:flutter/material.dart';

import '../models/movimiento_model.dart';
import '../services/auth_service.dart';
import '../services/movimiento_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/movimiento_card.dart';
import 'detalle_movimiento_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final MovimientoService servicio = MovimientoService();

  final TextEditingController buscarController = TextEditingController();

  late Stream<List<MovimientoModel>> streamMovimientos;

  String filtroSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    streamMovimientos = servicio.obtenerMovimientos();
  }

  // Aplica la búsqueda y el filtro sobre los datos que llegan de Firestore.
  List<MovimientoModel> filtrar(List<MovimientoModel> movimientos) {
    String texto = buscarController.text.toLowerCase();

    return movimientos.where((movimiento) {
      bool cumpleFiltro =
          filtroSeleccionado == 'Todos' ||
          movimiento.tipo == filtroSeleccionado;

      bool cumpleBusqueda =
          movimiento.descripcion.toLowerCase().contains(texto) ||
          movimiento.categoriaNombre.toLowerCase().contains(texto);

      return cumpleFiltro && cumpleBusqueda;
    }).toList();
  }

  // Filtro con el estilo del segundo corte: gris si no está elegido y
  // de color (azul grisáceo, verde o rojo) cuando está elegido.
  Widget chipFiltro(String titulo, String valor, Color color) {
    bool seleccionado = filtroSeleccionado == valor;

    return GestureDetector(
      onTap: () {
        setState(() {
          filtroSeleccionado = valor;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            color: seleccionado ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              label: 'Buscar movimiento',
              controller: buscarController,
              icono: Icons.search,
              onChanged: (texto) {
                setState(() {});
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                chipFiltro('Todos', 'Todos', colorTodos),
                const SizedBox(width: 8),
                chipFiltro('Ingresos', 'Ingreso', colorIngreso),
                const SizedBox(width: 8),
                chipFiltro('Gastos', 'Gasto', colorGasto),
              ],
            ),

            const SizedBox(height: 15),

            Expanded(
              child: StreamBuilder<List<MovimientoModel>>(
                stream: streamMovimientos,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(AuthService.mensajeError(snapshot.error!)),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<MovimientoModel> resultados = filtrar(snapshot.data!);

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Movimientos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${resultados.length} encontrados',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: resultados.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 55,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text('No se encontraron movimientos'),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: resultados.length,
                                itemBuilder: (context, index) {
                                  MovimientoModel movimiento =
                                      resultados[index];
                                  return MovimientoCard(
                                    movimiento: movimiento,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetalleMovimientoScreen(
                                                movimientoId: movimiento.id,
                                              ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: colorVerde,
        foregroundColor: Colors.white,
        child: const Icon(Icons.home),
      ),
    );
  }
}
