import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Input extends StatelessWidget {
  final Function(String)? onSubmit;
  final TextInputAction? textInputAction;
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final int? maxText;
  final Pattern? whiteList;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const Input({
    super.key,
    this.onSubmit,
    this.textInputAction,
    this.hint,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.maxText,
    this.whiteList,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      textInputAction: textInputAction ?? TextInputAction.done,
      keyboardType: keyboardType ?? TextInputType.text,
      onFieldSubmitted: onSubmit,
      controller: controller,
      onChanged: onChanged,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxText),
        FilteringTextInputFormatter.allow(whiteList ?? RegExp('([\\S])'))
      ],
      style: const TextStyle(
          fontSize: 16, color: Color.fromARGB(255, 26, 26, 26), height: 1.35),
      decoration: InputDecoration(
          prefixIcon: Icon(
            prefixIcon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          filled: true,
          fillColor: const Color.fromARGB(102, 230, 230, 230),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(width: 1, color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(width: 1, color: Colors.grey),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(width: 1, color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).primaryColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(width: 1, color: Colors.red),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey)),
    );
  }
}

