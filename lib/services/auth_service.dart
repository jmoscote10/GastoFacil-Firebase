import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/constants.dart';

// Maneja el registro, inicio y cierre de sesión con Firebase Authentication.
class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  User? get usuarioActual => auth.currentUser;

  // Crea la cuenta en Authentication y el documento del usuario en "users".
  // La contraseña NO se guarda en Firestore, solo la administra Authentication.
  Future<void> registrarUsuario(
    String nombre,
    String email,
    String password,
  ) async {
    UserCredential credencial = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = credencial.user!.uid;

    await db.collection('users').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });

    await crearCategoriasIniciales(uid);
  }

  // Crea las categorías que GastoFácil ya tenía en las unidades anteriores.
  Future<void> crearCategoriasIniciales(String uid) async {
    WriteBatch lote = db.batch();

    categoriasIniciales.forEach((nombre, tipo) {
      DocumentReference referencia = db.collection('categories').doc();
      lote.set(referencia, {
        'id': referencia.id,
        'userId': uid,
        'nombre': nombre,
        'tipo': tipo,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
    });

    await lote.commit();
  }

  Future<void> iniciarSesion(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> cerrarSesion() async {
    await auth.signOut();
  }

  Future<String> obtenerNombre() async {
    if (usuarioActual == null) return '';

    DocumentSnapshot documento = await db
        .collection('users')
        .doc(usuarioActual!.uid)
        .get();

    if (!documento.exists) return '';

    Map<String, dynamic> datos = documento.data() as Map<String, dynamic>;
    return datos['nombre'] ?? '';
  }

  // Traduce los códigos de error de Firebase a mensajes en español.
  static String mensajeError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Correo o contraseña incorrectos';
        case 'invalid-email':
          return 'El correo no es válido';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con ese correo';
        case 'weak-password':
          return 'La contraseña debe tener mínimo 6 caracteres';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde';
        case 'network-request-failed':
          return 'Sin conexión a internet';
        default:
          return 'Error de autenticación: ${error.code}';
      }
    }

    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'No tienes permiso para realizar esta acción';
      }
      if (error.code == 'unavailable') {
        return 'Sin conexión con la base de datos';
      }
      return 'Error de Firebase: ${error.code}';
    }

    return 'Ocurrió un error inesperado';
  }
}
