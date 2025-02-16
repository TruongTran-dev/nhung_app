import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String? text;
  final Function()? onTap;

  ///for disable button
  final bool isDisable;

  const PrimaryButton({
    Key? key,
    this.text,
    this.onTap,
    this.isDisable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          elevation: const MaterialStatePropertyAll(0),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: isDisable
                  ? BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                      style: BorderStyle.solid)
                  : BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
            ),
          ),
          overlayColor: MaterialStatePropertyAll(
            Theme.of(context).primaryColor,
          ),
          backgroundColor: MaterialStatePropertyAll(
              isDisable ? Colors.transparent : Theme.of(context).primaryColor),
          foregroundColor: const MaterialStatePropertyAll(Colors.transparent),
          textStyle: const MaterialStatePropertyAll(
            TextStyle(color: Colors.white),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          constraints:  BoxConstraints(
            minWidth: 100,
            maxWidth: MediaQuery.of(context).size.width *0.7,
          ),
          child: Text(
            text ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isDisable ? Theme.of(context).primaryColor : Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
