import 'package:flutter/material.dart';

import '../models/categoria_model.dart';
import '../models/movimiento_model.dart';
import '../services/categoria_service.dart';
import '../utils/constants.dart';
import 'custom_button.dart';
import 'custom_container.dart';
import 'custom_text_field.dart';

// Formulario de movimiento. Lo usan la pantalla de registro y la de edición.
// Si recibe un movimiento, carga sus datos para editarlos.
class MovimientoForm extends StatefulWidget {
  final MovimientoModel? movimiento;
  final String textoBoton;
  final Future<void> Function(MovimientoModel movimiento) onGuardar;

  const MovimientoForm({
    super.key,
    this.movimiento,
    required this.textoBoton,
    required this.onGuardar,
  });

  @override
  State<MovimientoForm> createState() => _MovimientoFormState();
}

class _MovimientoFormState extends State<MovimientoForm> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController valorController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final CategoriaService categoriaService = CategoriaService();

  late Stream<List<CategoriaModel>> streamCategorias;

  String tipoSeleccionado = 'Ingreso';
  String? categoriaIdSeleccionada;
  DateTime fechaSeleccionada = DateTime.now();
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    streamCategorias = categoriaService.obtenerCategorias();

    // Modo edición: se cargan los datos existentes.
    MovimientoModel? movimiento = widget.movimiento;
    if (movimiento != null) {
      tipoSeleccionado = movimiento.tipo;
      valorController.text = movimiento.valor.toStringAsFixed(0);
      descripcionController.text = movimiento.descripcion;
      categoriaIdSeleccionada = movimiento.categoriaId;
      fechaSeleccionada = movimiento.fechaMovimiento;
    }
  }

  Future<void> seleccionarFecha() async {
    DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (nuevaFecha != null) {
      setState(() {
        fechaSeleccionada = nuevaFecha;
      });
    }
  }

  Future<void> guardar(List<CategoriaModel> categorias) async {
    // Evita guardar dos veces si se toca el botón muy rápido.
    if (guardando) return;
    if (!formKey.currentState!.validate()) return;

    CategoriaModel categoria = categorias.firstWhere(
      (c) => c.id == categoriaIdSeleccionada,
    );

    MovimientoModel movimiento = MovimientoModel(
      id: widget.movimiento?.id ?? '',
      userId: widget.movimiento?.userId ?? '',
      tipo: tipoSeleccionado,
      valor: double.parse(valorController.text.replaceAll(',', '.')),
      categoriaId: categoria.id,
      categoriaNombre: categoria.nombre,
      descripcion: descripcionController.text.trim(),
      fechaMovimiento: fechaSeleccionada,
    );

    setState(() {
      guardando = true;
    });

    await widget.onGuardar(movimiento);

    if (mounted) {
      setState(() {
        guardando = false;
      });
    }
  }

  // Selector Ingreso / Gasto con el estilo del segundo corte:
  // fondo gris y la opción elegida en verde claro o rosado.
  Widget chipTipo(String tipo, Color color) {
    bool seleccionado = tipoSeleccionado == tipo;
    bool esIngreso = tipo == 'Ingreso';

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            tipoSeleccionado = tipo;
            // Al cambiar el tipo se limpia la categoría elegida.
            categoriaIdSeleccionada = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: seleccionado
                ? (esIngreso ? Colors.green.shade100 : Colors.red.shade100)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              tipo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: seleccionado
                    ? (esIngreso ? Colors.green.shade800 : Colors.red.shade800)
                    : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    valorController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoriaModel>>(
      stream: streamCategorias,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('No se pudieron cargar categorías'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Solo se muestran las categorías del tipo seleccionado.
        List<CategoriaModel> categorias = snapshot.data!
            .where((c) => c.tipo == tipoSeleccionado)
            .toList();

        bool categoriaValida = categorias.any(
          (c) => c.id == categoriaIdSeleccionada,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: CustomContainer(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de movimiento',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        chipTipo('Ingreso', colorIngreso),
                        chipTipo('Gasto', colorGasto),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Valor',
                    controller: valorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (texto) {
                      if (texto == null || texto.trim().isEmpty) {
                        return 'El valor es obligatorio';
                      }
                      double? valor = double.tryParse(
                        texto.replaceAll(',', '.'),
                      );
                      if (valor == null) {
                        return 'El valor debe ser numérico';
                      }
                      if (valor <= 0) {
                        return 'El valor debe ser mayor que cero';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Categoría',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  if (categorias.isEmpty)
                    const Text(
                      'No tienes categorías de este tipo. '
                      'Créalas en la pantalla Categorías.',
                      style: TextStyle(color: colorGasto),
                    )
                  else
                    DropdownButtonFormField<String>(
                      key: ValueKey(tipoSeleccionado),
                      initialValue: categoriaValida
                          ? categoriaIdSeleccionada
                          : null,
                      hint: const Text('Selecciona una categoría'),
                      items: categorias.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria.id,
                          child: Text(categoria.nombre),
                        );
                      }).toList(),
                      onChanged: (nuevaCategoria) {
                        setState(() {
                          categoriaIdSeleccionada = nuevaCategoria;
                        });
                      },
                      validator: (valor) {
                        if (valor == null) {
                          return 'Selecciona una categoría';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 18),

                  CustomTextField(
                    label: 'Descripción',
                    controller: descripcionController,
                    maxLines: 3,
                    validator: (texto) {
                      if (texto == null || texto.trim().isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Fecha',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  InkWell(
                    onTap: seleccionarFecha,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatearFecha(fechaSeleccionada)),
                          const Icon(Icons.calendar_today, color: colorAzul),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  guardando
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          texto: widget.textoBoton,
                          icono: Icons.save,
                          onPressed: () => guardar(categorias),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
