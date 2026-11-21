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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colorTarjeta,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 85,
              decoration: BoxDecoration(
                color: colorMovimiento,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
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

                          const SizedBox(height: 4),

                          Text(
                            movimiento.descripcion,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${movimiento.categoriaNombre} · ${formatearFecha(movimiento.fechaMovimiento)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '$signo\$${movimiento.valor.toStringAsFixed(0)}',
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
    );
  }
}
