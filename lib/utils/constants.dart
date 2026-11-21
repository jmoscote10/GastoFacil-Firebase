import 'package:flutter/material.dart';

const String nombreApp = 'GastoFácil';

const Color colorPrincipal = Color(0xFF17324D);
const Color colorSecundario = Color(0xFF8498AE);
const Color colorIngreso = Colors.green;
const Color colorGasto = Colors.red;
const Color colorFondo = Color(0xFFF7F7F7);
const Color colorTarjeta = Colors.white;

// Colores del segundo corte (estaban escritos directamente en las pantallas).
const Color colorVerde = Color(0xFF176B4D); // saldo, botones, botón + y menú
const Color colorAzul = Color(0xFF2C3E50); // bordes activos, calendario
const Color colorTodos = Color(0xFF627D98); // filtro "Todos" del historial
const Color colorError = Colors.redAccent; // mensajes de error
const String rutaLogo = 'assets/Logo_Gastofacil.jpeg';

// Categorías que se crean automáticamente al registrar un usuario.
// Son las mismas de las unidades anteriores, ahora con su tipo.
const Map<String, String> categoriasIniciales = {
  'Comida': 'Gasto',
  'Transporte': 'Gasto',
  'Membresía': 'Gasto',
  'Servicios': 'Gasto',
  'Estudio': 'Gasto',
  'Salud': 'Gasto',
  'Otros': 'Gasto',
  'Trabajo': 'Ingreso',
  'Otros ingresos': 'Ingreso',
};

String formatearFecha(DateTime fecha) {
  String dia = fecha.day.toString().padLeft(2, '0');
  String mes = fecha.month.toString().padLeft(2, '0');
  String anio = fecha.year.toString();

  return '$dia/$mes/$anio';
}

// Muestra el valor con separador de miles, como en el segundo corte: 1,000,000
String formatearMonto(double monto) {
  return monto
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
}

void mostrarMensaje(BuildContext context, String mensaje, Color color) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
}
