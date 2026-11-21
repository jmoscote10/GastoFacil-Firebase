import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final IconData? icono;

  const CustomButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    // Mismo estilo del botón del segundo corte: verde, sin sombra y redondeado.
    const TextStyle estiloTexto = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorVerde,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: icono == null
            ? Text(texto, style: estiloTexto)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icono),
                  const SizedBox(width: 8),
                  Text(texto, style: estiloTexto),
                ],
              ),
      ),
    );
  }
}
