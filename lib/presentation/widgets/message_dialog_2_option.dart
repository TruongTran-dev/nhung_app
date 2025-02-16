import 'package:flutter/material.dart';

class MessageDialog2Option extends StatelessWidget {
  final String? title;
  final String? content;
  final Function()? onCancel;
  final String? cancelLabel;
  final Function()? onOk;
  final String? okLabel;

  const MessageDialog2Option({
    Key? key,
    this.title,
    this.content,
    this.onCancel,
    this.cancelLabel,
    this.onOk,
    this.okLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title == null
          ? null
          : Text(
              title!,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
      content: content == null
          ? null
          : Text(
              content!,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (onCancel != null) {
              onCancel!();
            }
          },
          child: Text(
            cancelLabel ?? 'Cancel',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) {
                onOk!();
              }
            },
            child: Text(
              okLabel ?? 'OK',
              style: const TextStyle(fontSize: 16, color: Color(0xffCA0000)),
            )),
      ],
    );
  }
}
