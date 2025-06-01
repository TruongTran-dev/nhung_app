import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            if (text != null) ...[
              SizedBox(height: 10),
              Text(text!, style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
