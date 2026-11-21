import 'package:cloud_firestore/cloud_firestore.dart';

// Representa un ingreso o un gasto guardado en la colección "movements".
class MovimientoModel {
  final String id;
  final String userId;
  final String tipo; // 'Ingreso' o 'Gasto'
  final double valor;
  final String categoriaId;
  final String categoriaNombre;
  final String descripcion;
  final DateTime fechaMovimiento;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  MovimientoModel({
    this.id = '',
    required this.userId,
    required this.tipo,
    required this.valor,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.descripcion,
    required this.fechaMovimiento,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  // Convierte el objeto en un mapa para enviarlo a Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tipo': tipo,
      'valor': valor,
      'categoriaId': categoriaId,
      'categoriaNombre': categoriaNombre,
      'descripcion': descripcion,
      'fechaMovimiento': Timestamp.fromDate(fechaMovimiento),
    };
  }

  // Crea el objeto a partir de un documento leído desde Firestore.
  factory MovimientoModel.fromFirestore(DocumentSnapshot documento) {
    Map<String, dynamic> datos = documento.data() as Map<String, dynamic>;

    return MovimientoModel(
      id: documento.id,
      userId: datos['userId'] ?? '',
      tipo: datos['tipo'] ?? 'Gasto',
      valor: (datos['valor'] ?? 0).toDouble(),
      categoriaId: datos['categoriaId'] ?? '',
      categoriaNombre: datos['categoriaNombre'] ?? '',
      descripcion: datos['descripcion'] ?? '',
      fechaMovimiento:
          convertirFecha(datos['fechaMovimiento']) ?? DateTime.now(),
      fechaCreacion: convertirFecha(datos['fechaCreacion']),
      fechaActualizacion: convertirFecha(datos['fechaActualizacion']),
    );
  }

  static DateTime? convertirFecha(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }
    return null;
  }
}
