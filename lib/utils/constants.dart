import 'package:flutter/material.dart';

const String nombreApp = 'GastoFácil';

const Color colorPrincipal = Color(0xFF17324D);
const Color colorSecundario = Color(0xFF8498AE);
const Color colorIngreso = Colors.green;
const Color colorGasto = Colors.red;
const Color colorFondo = Color(0xFFF7F7F7);
const Color colorTarjeta = Colors.white;

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

void mostrarMensaje(BuildContext context, String mensaje, Color color) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
}
