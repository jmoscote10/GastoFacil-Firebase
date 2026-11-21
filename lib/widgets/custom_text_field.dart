import 'package:flutter/material.dart';

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
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: icono == null ? null : Icon(icono),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
