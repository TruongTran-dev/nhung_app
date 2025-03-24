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
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: isDisable
                  ? BorderSide(color: Theme.of(context).primaryColor, width: 2, style: BorderStyle.solid)
                  : BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          overlayColor: WidgetStatePropertyAll(Theme.of(context).primaryColor),
          backgroundColor: WidgetStatePropertyAll(isDisable ? Colors.transparent : Theme.of(context).primaryColor),
          foregroundColor: const WidgetStatePropertyAll(Colors.transparent),
          textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          // constraints:  BoxConstraints(
          //   minWidth: 100,
          //   maxWidth: MediaQuery.of(context).size.width *0.7,
          // ),
          child: Text(
            text ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDisable ? Theme.of(context).primaryColor : Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
