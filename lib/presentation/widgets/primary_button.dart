import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String? text;
  final Function()? onTap;

  ///for disable button
  final bool isDisable;

  const PrimaryButton({
    super.key,
    this.text,
    this.onTap,
    this.isDisable = false,
  });

  @override
  Widget build(BuildContext context) {
    Color disableColor = Colors.grey.withValues(alpha: 0.4);
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: isDisable ? null : onTap,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: isDisable
                  ? BorderSide(color: disableColor, width: 2)
                  : BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          overlayColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
          backgroundColor: WidgetStatePropertyAll(isDisable ? Colors.transparent : Theme.of(context).primaryColor),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            text ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDisable ? disableColor : Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
