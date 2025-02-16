import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputPasswordField extends StatelessWidget {
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final String? hint;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final int? maxText;
  final Pattern? whiteList;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? initText;
  final Function()? onTapSuffixIcon;
  final String? Function(String?)? validator;

  const InputPasswordField({
    Key? key,
    this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction,
    this.hint,
    required this.controller,
    this.onChanged,
    this.keyboardType,
    this.maxText,
    this.whiteList,
    this.obscureText = false,
    this.initText,
    this.onTapSuffixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initText != null) {
      controller.text = initText!;
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: initText!.length,
      );
    }

    return TextFormField(
      focusNode: focusNode,
      textInputAction: textInputAction ?? TextInputAction.done,
      keyboardType: keyboardType ?? TextInputType.text,
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxText),
        FilteringTextInputFormatter.allow(whiteList ?? RegExp('([\\S])'))
      ],
      style: const TextStyle(
          fontSize: 16, color: Color.fromARGB(255, 26, 26, 26), height: 1.35),
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: InkWell(
            onTap: onTapSuffixIcon,
            child: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
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
