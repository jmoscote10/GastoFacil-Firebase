# GastoFácil – Firebase

Aplicación móvil en Flutter para registrar y controlar ingresos y gastos personales.
Unidad 3 de Computación Móvil: persistencia remota, autenticación y sincronización.

## Autores

- Jesús Moscote Fernández
- Andrés Moreno Cuentas

Universidad de la Costa (CUC) – Computación Móvil, 2026.

## Tecnologías

- Flutter y Dart
- Firebase Authentication (correo y contraseña)
- Cloud Firestore (base de datos remota)

## Colecciones en Firestore

| Colección    | Campos principales |
|--------------|--------------------|
| `users`      | uid, nombre, email, fechaRegistro |
| `categories` | id, userId, nombre, tipo, fechaCreacion |
| `movements`  | id, userId, tipo, valor, categoriaId, categoriaNombre, descripcion, fechaMovimiento, fechaCreacion, fechaActualizacion |

Cada documento guarda el `userId` del dueño. Las contraseñas no se guardan en
Firestore; las administra Firebase Authentication.

## Pantallas

1. Inicio de sesión
2. Registro de usuario
3. Inicio (saldo, ingresos, gastos y últimos movimientos)
4. Historial (búsqueda y filtros en tiempo real)
5. Registro de movimiento
6. Detalle del movimiento (editar y eliminar con confirmación)
7. Edición del movimiento
8. Categorías (gestión: crear, editar y eliminar)

## Seguridad

Las reglas están en [`firestore.rules`](firestore.rules):

- Sin sesión no se puede leer ni escribir.
- Cada usuario solo puede leer y modificar los documentos cuyo `userId`
  coincide con su `request.auth.uid`.

## Ejecutar

```bash
flutter pub get
flutter run
```
