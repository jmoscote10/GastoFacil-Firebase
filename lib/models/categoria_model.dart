import 'package:cloud_firestore/cloud_firestore.dart';

// Representa una categoría guardada en la colección "categories".
class CategoriaModel {
  final String id;
  final String userId;
  final String nombre;
  final String tipo; // 'Ingreso' o 'Gasto'

  CategoriaModel({
    this.id = '',
    required this.userId,
    required this.nombre,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'nombre': nombre, 'tipo': tipo};
  }

  factory CategoriaModel.fromFirestore(DocumentSnapshot documento) {
    Map<String, dynamic> datos = documento.data() as Map<String, dynamic>;

    return CategoriaModel(
      id: documento.id,
      userId: datos['userId'] ?? '',
      nombre: datos['nombre'] ?? '',
      tipo: datos['tipo'] ?? 'Gasto',
    );
  }
}
