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
        foregroundColor: colorPrincipal,
        elevation: 1,
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
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: filtroSeleccionado == 'Todos',
                    onSelected: (seleccionado) {
                      setState(() {
                        filtroSeleccionado = 'Todos';
                      });
                    },
                  ),
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: ChoiceChip(
                    label: const Text('Ingresos'),
                    selected: filtroSeleccionado == 'Ingreso',
                    selectedColor: colorIngreso.withValues(alpha: 0.25),
                    onSelected: (seleccionado) {
                      setState(() {
                        filtroSeleccionado = 'Ingreso';
                      });
                    },
                  ),
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: ChoiceChip(
                    label: const Text('Gastos'),
                    selected: filtroSeleccionado == 'Gasto',
                    selectedColor: colorGasto.withValues(alpha: 0.25),
                    onSelected: (seleccionado) {
                      setState(() {
                        filtroSeleccionado = 'Gasto';
                      });
                    },
                  ),
                ),
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
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.home),
      ),
    );
  }
}
