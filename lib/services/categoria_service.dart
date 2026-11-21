import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/categoria_model.dart';

// Operaciones CRUD de la colección "categories" en Cloud Firestore.
class CategoriaService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  CollectionReference get coleccion => db.collection('categories');

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> agregarCategoria(String nombre, String tipo) async {
    DocumentReference referencia = coleccion.doc();

    await referencia.set({
      'id': referencia.id,
      'userId': uid,
      'nombre': nombre,
      'tipo': tipo,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }

  // Consulta en tiempo real las categorías del usuario autenticado.
  Stream<List<CategoriaModel>> obtenerCategorias() {
    return coleccion.where('userId', isEqualTo: uid).snapshots().map((
      consulta,
    ) {
      List<CategoriaModel> lista = consulta.docs
          .map((documento) => CategoriaModel.fromFirestore(documento))
          .toList();

      lista.sort((a, b) => a.nombre.compareTo(b.nombre));
      return lista;
    });
  }

  // Cambia el nombre de la categoría y también en los movimientos que la usan,
  // así los datos quedan sincronizados.
  Future<void> actualizarCategoria(CategoriaModel categoria) async {
    WriteBatch lote = db.batch();

    lote.update(coleccion.doc(categoria.id), {'nombre': categoria.nombre});

    QuerySnapshot movimientos = await db
        .collection('movements')
        .where('userId', isEqualTo: uid)
        .where('categoriaId', isEqualTo: categoria.id)
        .get();

    for (QueryDocumentSnapshot documento in movimientos.docs) {
      lote.update(documento.reference, {
        'categoriaNombre': categoria.nombre,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });
    }

    await lote.commit();
  }

  // Revisa si algún movimiento usa la categoría antes de eliminarla.
  Future<bool> categoriaEnUso(String categoriaId) async {
    QuerySnapshot consulta = await db
        .collection('movements')
        .where('userId', isEqualTo: uid)
        .where('categoriaId', isEqualTo: categoriaId)
        .limit(1)
        .get();

    return consulta.docs.isNotEmpty;
  }

  Future<void> eliminarCategoria(String id) async {
    await coleccion.doc(id).delete();
  }
}
