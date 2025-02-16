import 'package:flutter/material.dart';

class CustomCheckBox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

   const CustomCheckBox({Key? key,required this.value,required this.onChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    if (widget.onChanged == null) {
      if (!widget.value) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  width: 1, color: const Color.fromARGB(64, 130, 130, 130)),
              color: const Color.fromARGB(51, 230, 230, 230)),
        );
      }
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border:
            Border.all(width: 1, color: const Color.fromARGB(128, 220, 68, 5)),
            color: const Color.fromARGB(128, 220, 68, 5)),
        child: const Center(child: Icon(Icons.check, color: Colors.white, size: 18)),
      );
    } else {
      if (!widget.value) {
        return GestureDetector(
          onTap: () {
            widget.onChanged!(!widget.value);
          },
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    width: 1, color: const Color.fromARGB(128, 130, 130, 130)),
                color: const Color.fromARGB(103, 230, 230, 230)),
          ),
        );
      }
      return GestureDetector(
        onTap: () {
          widget.onChanged!(!widget.value);
        },
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border:
              Border.all(width: 1, color: Theme.of(context).primaryColor),
              color: Theme.of(context).primaryColor),
          child:
          const Center(child: Icon(Icons.check, color: Colors.white, size: 18)),
        ),
      );
    }
  }
}
