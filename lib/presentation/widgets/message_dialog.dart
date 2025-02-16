import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final Function()? onClose;
  final String? buttonLabel;

  const MessageDialog({
    Key? key,
    this.title,
    this.content,
    this.onClose,
    this.buttonLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
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
            if (onClose != null) {
              onClose!();
            }
          },
          child: Text(
            buttonLabel ?? 'OK',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
