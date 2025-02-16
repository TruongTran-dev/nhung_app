import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class ButtonSwitch extends StatelessWidget {
  final String title;
  final Function(bool) onToggle;
  final bool value;
  final Icon? activeIcon;
  final Icon? inActiveIcon;

  const ButtonSwitch({
    Key? key,
    required this.title,
    required this.onToggle,
    this.value = false,
    this.activeIcon,
    this.inActiveIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          FlutterSwitch(
            width: 40.0,
            height: 20.0,
            toggleSize: 18.0,
            value: value,
            borderRadius: 10.0,
            padding: 1.0,
            activeColor: const Color(0xFF81c784),
            inactiveColor: Colors.grey,
            activeIcon: activeIcon ?? const SizedBox.shrink(),
            inactiveIcon: inActiveIcon ?? const SizedBox.shrink(),
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }
}
