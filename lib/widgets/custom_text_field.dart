import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? icono;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool ocultarTexto;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.icono,
    this.onChanged,
    this.validator,
    this.ocultarTexto = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      obscureText: ocultarTexto,
      // Los colores, el relleno gris y los bordes redondeados vienen del
      // tema en main.dart (mismo estilo del segundo corte).
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: icono == null ? null : Icon(icono, color: colorAzul),
      ),
    );
  }
}
