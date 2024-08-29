import 'package:flutter/material.dart';

InputDecoration xInputDecoration({String? hintText}) => InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          8,
        ),
        borderSide: const BorderSide(
          color: Colors.transparent,
        ),
      ),
      contentPadding: const EdgeInsets.all(14),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black),
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      filled: true,
    );

class GlobalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool isPhoneNumberField;
  final int maxLength;
  final int minLines;
  final int maxLines;

  // ignore: use_super_parameters
  const GlobalTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.isPhoneNumberField = false,
    this.maxLength = 100,
    this.minLines = 1,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      scrollPadding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: xInputDecoration(hintText: hintText).copyWith(
        counterText: "",
        hintStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.black) : null,
      ),
      validator: validator,
      onChanged: (value) {
        if (isPhoneNumberField) {
          if (value.length == 10) {
            FocusScope.of(context).requestFocus(FocusNode());
          } else if (value.isEmpty) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        }
        if (onChanged != null) {
          onChanged!(value);
        }
      },
    );
  }
}
