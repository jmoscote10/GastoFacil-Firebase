import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/movimiento_model.dart';

// Operaciones CRUD de la colección "movements" en Cloud Firestore.
class MovimientoService {
  final CollectionReference coleccion = FirebaseFirestore.instance.collection(
    'movements',
  );

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // CREAR: guarda un nuevo movimiento del usuario autenticado.
  Future<void> agregarMovimiento(MovimientoModel movimiento) async {
    DocumentReference referencia = coleccion.doc();

    Map<String, dynamic> datos = movimiento.toMap();
    datos['id'] = referencia.id;
    datos['userId'] = uid;
    datos['fechaCreacion'] = FieldValue.serverTimestamp();
    datos['fechaActualizacion'] = FieldValue.serverTimestamp();

    await referencia.set(datos);
  }

  // CONSULTAR: escucha en tiempo real solo los movimientos del usuario.
  // Cada vez que cambia Firestore, el Stream envía la lista actualizada.
  Stream<List<MovimientoModel>> obtenerMovimientos() {
    return coleccion.where('userId', isEqualTo: uid).snapshots().map((
      consulta,
    ) {
      List<MovimientoModel> lista = consulta.docs
          .map((documento) => MovimientoModel.fromFirestore(documento))
          .toList();

      // Del más reciente al más antiguo.
      lista.sort((a, b) => b.fechaMovimiento.compareTo(a.fechaMovimiento));
      return lista;
    });
  }

  // Consulta un movimiento por id en tiempo real (pantalla de detalle).
  Stream<MovimientoModel?> obtenerMovimiento(String id) {
    return coleccion.doc(id).snapshots().map((documento) {
      if (!documento.exists) return null;
      return MovimientoModel.fromFirestore(documento);
    });
  }

  // ACTUALIZAR: modifica el documento existente en Firestore.
  Future<void> actualizarMovimiento(MovimientoModel movimiento) async {
    Map<String, dynamic> datos = movimiento.toMap();
    datos['userId'] = uid;
    datos['fechaActualizacion'] = FieldValue.serverTimestamp();

    await coleccion.doc(movimiento.id).update(datos);
  }

  // ELIMINAR: borra el documento en Firestore.
  Future<void> eliminarMovimiento(String id) async {
    await coleccion.doc(id).delete();
  }

  double calcularIngresos(List<MovimientoModel> movimientos) {
    double totalIngresos = 0;

    for (MovimientoModel movimiento in movimientos) {
      if (movimiento.tipo == 'Ingreso') {
        totalIngresos = totalIngresos + movimiento.valor;
      }
    }

    return totalIngresos;
  }

  double calcularGastos(List<MovimientoModel> movimientos) {
    double totalGastos = 0;

    for (MovimientoModel movimiento in movimientos) {
      if (movimiento.tipo == 'Gasto') {
        totalGastos = totalGastos + movimiento.valor;
      }
    }

    return totalGastos;
  }

  // saldo = suma de ingresos - suma de gastos
  double calcularSaldo(List<MovimientoModel> movimientos) {
    return calcularIngresos(movimientos) - calcularGastos(movimientos);
  }
}
