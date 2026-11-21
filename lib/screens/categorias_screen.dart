import 'package:flutter/material.dart';

import '../models/categoria_model.dart';
import '../services/auth_service.dart';
import '../services/categoria_service.dart';
import '../utils/constants.dart';

// Pantalla de gestión: el usuario administra sus propias categorías.
class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService servicio = CategoriaService();
  late Stream<List<CategoriaModel>> streamCategorias;

  @override
  void initState() {
    super.initState();
    streamCategorias = servicio.obtenerCategorias();
  }

  // Diálogo para crear (categoria == null) o editar una categoría.
  Future<void> abrirFormulario({CategoriaModel? categoria}) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nombreController = TextEditingController(
      text: categoria?.nombre ?? '',
    );
    String tipo = categoria?.tipo ?? 'Gasto';
    bool esEdicion = categoria != null;

    bool? guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialogo) {
            return AlertDialog(
              title: Text(esEdicion ? 'Editar categoría' : 'Nueva categoría'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // El tipo solo se elige al crear la categoría.
                    if (!esEdicion)
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Ingreso'),
                              selected: tipo == 'Ingreso',
                              selectedColor: colorIngreso.withValues(
                                alpha: 0.25,
                              ),
                              onSelected: (seleccionado) {
                                setStateDialogo(() {
                                  tipo = 'Ingreso';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Gasto'),
                              selected: tipo == 'Gasto',
                              selectedColor: colorGasto.withValues(alpha: 0.25),
                              onSelected: (seleccionado) {
                                setStateDialogo(() {
                                  tipo = 'Gasto';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    String nombre = nombreController.text.trim();

    if (guardar != true) return;

    try {
      if (esEdicion) {
        await servicio.actualizarCategoria(
          CategoriaModel(
            id: categoria.id,
            userId: categoria.userId,
            nombre: nombre,
            tipo: categoria.tipo,
          ),
        );
      } else {
        await servicio.agregarCategoria(nombre, tipo);
      }

      if (mounted) {
        mostrarMensaje(
          context,
          esEdicion ? 'Categoría actualizada' : 'Categoría creada',
          colorIngreso,
        );
      }
    } catch (error) {
      if (mounted) {
        mostrarMensaje(context, AuthService.mensajeError(error), colorGasto);
      }
    }
  }

  Future<void> eliminar(CategoriaModel categoria) async {
    try {
      // Solo se elimina si ningún movimiento la está usando.
      bool enUso = await servicio.categoriaEnUso(categoria.id);

      if (!mounted) return;

      if (enUso) {
        mostrarMensaje(
          context,
          'No se puede eliminar: hay movimientos con esta categoría',
          colorGasto,
        );
        return;
      }

      bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar categoría'),
          content: Text('¿Deseas eliminar la categoría "${categoria.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: colorGasto),
              ),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      await servicio.eliminarCategoria(categoria.id);

      if (mounted) {
        mostrarMensaje(context, 'Categoría eliminada', colorIngreso);
      }
    } catch (error) {
      if (mounted) {
        mostrarMensaje(context, AuthService.mensajeError(error), colorGasto);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: Colors.white,
        foregroundColor: colorPrincipal,
        elevation: 1,
      ),
      body: StreamBuilder<List<CategoriaModel>>(
        stream: streamCategorias,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(AuthService.mensajeError(snapshot.error!)),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<CategoriaModel> categorias = snapshot.data!;

          if (categorias.isEmpty) {
            return const Center(child: Text('No tienes categorías todavía'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              CategoriaModel categoria = categorias[index];
              bool esIngreso = categoria.tipo == 'Ingreso';
              Color color = esIngreso ? colorIngreso : colorGasto;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
                      color: color,
                    ),
                  ),
                  title: Text(categoria.nombre),
                  subtitle: Text(
                    categoria.tipo,
                    style: TextStyle(color: color),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => abrirFormulario(categoria: categoria),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: colorGasto),
                        onPressed: () => eliminar(categoria),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirFormulario(),
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
