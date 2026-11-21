import 'package:flutter/material.dart';

import '../models/movimiento_model.dart';
import '../services/auth_service.dart';
import '../services/movimiento_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_container.dart';
import '../widgets/movimiento_card.dart';
import 'categorias_screen.dart';
import 'detalle_movimiento_screen.dart';
import 'historial_screen.dart';
import 'registro_movimiento_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovimientoService servicio = MovimientoService();
  final AuthService authService = AuthService();

  late Stream<List<MovimientoModel>> streamMovimientos;
  String nombreUsuario = '';

  @override
  void initState() {
    super.initState();
    streamMovimientos = servicio.obtenerMovimientos();
    cargarNombre();
  }

  Future<void> cargarNombre() async {
    try {
      String nombre = await authService.obtenerNombre();
      if (mounted) {
        setState(() {
          nombreUsuario = nombre;
        });
      }
    } catch (error) {
      // Si falla solo se muestra el saludo sin nombre.
    }
  }

  void abrirPantalla(Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => pantalla));
  }

  Future<void> cerrarSesion() async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // ControlSesion detecta el cambio y muestra el login.
      await authService.cerrarSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: colorPrincipal,
        elevation: 1,
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: colorPrincipal),
            SizedBox(width: 8),
            Text(nombreApp, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => abrirPantalla(const HistorialScreen()),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => abrirPantalla(const CategoriasScreen()),
            icon: const Icon(Icons.category),
          ),
          IconButton(onPressed: cerrarSesion, icon: const Icon(Icons.logout)),
        ],
      ),
      // StreamBuilder: cada cambio en Firestore vuelve a dibujar el inicio.
      body: StreamBuilder<List<MovimientoModel>>(
        stream: streamMovimientos,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No se pudieron cargar los datos.\n'
                  '${AuthService.mensajeError(snapshot.error!)}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<MovimientoModel> movimientos = snapshot.data!;
          double ingresos = servicio.calcularIngresos(movimientos);
          double gastos = servicio.calcularGastos(movimientos);
          double saldo = servicio.calcularSaldo(movimientos);
          List<MovimientoModel> movimientosRecientes = movimientos
              .take(4)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                nombreUsuario.isEmpty ? 'Hola' : 'Hola, $nombreUsuario',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              CustomContainer(
                color: colorSecundario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Disponible',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${saldo.toStringAsFixed(0)} COP',
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

              Row(
                children: [
                  Expanded(
                    child: CustomContainer(
                      child: Column(
                        children: [
                          const Text(
                            'Ingresos',
                            style: TextStyle(color: colorIngreso),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '+ \$${ingresos.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: colorIngreso,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: CustomContainer(
                      child: Column(
                        children: [
                          const Text(
                            'Gastos',
                            style: TextStyle(color: colorGasto),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '- \$${gastos.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: colorGasto,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transacciones recientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => abrirPantalla(const HistorialScreen()),
                    child: const Text('Ver más'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (movimientosRecientes.isEmpty)
                const CustomContainer(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 45, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Todavía no hay movimientos registrados',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...movimientosRecientes.map(
                  (movimiento) => MovimientoCard(
                    movimiento: movimiento,
                    onTap: () => abrirPantalla(
                      DetalleMovimientoScreen(movimientoId: movimiento.id),
                    ),
                  ),
                ),

              const SizedBox(height: 70),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirPantalla(const RegistroMovimientoScreen()),
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: colorPrincipal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (indice) {
          if (indice == 1) {
            abrirPantalla(const HistorialScreen());
          }

          if (indice == 2) {
            abrirPantalla(const RegistroMovimientoScreen());
          }

          if (indice == 3) {
            abrirPantalla(const CategoriasScreen());
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Registrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categorías',
          ),
        ],
      ),
    );
  }
}
