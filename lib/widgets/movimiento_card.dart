import 'package:flutter/material.dart';

import '../models/movimiento_model.dart';
import '../utils/constants.dart';

class MovimientoCard extends StatelessWidget {
  final MovimientoModel movimiento;
  final VoidCallback? onTap;

  const MovimientoCard({super.key, required this.movimiento, this.onTap});

  @override
  Widget build(BuildContext context) {
    bool esIngreso = movimiento.tipo == 'Ingreso';

    Color colorMovimiento = esIngreso ? colorIngreso : colorGasto;

    String signo = esIngreso ? '+' : '-';

    // Estilo de la tarjeta del segundo corte: borde gris claro, sombra suave,
    // esquinas de 12 y franja de color a la izquierda.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colorTarjeta,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: colorMovimiento),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movimiento.tipo,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                movimiento.descripcion,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                '${movimiento.categoriaNombre}  •  ${formatearFecha(movimiento.fechaMovimiento)}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          '$signo\$ ${formatearMonto(movimiento.valor)} Cop',
                          style: TextStyle(
                            color: colorMovimiento,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
