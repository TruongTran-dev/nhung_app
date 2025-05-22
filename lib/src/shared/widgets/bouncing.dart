import 'package:flutter/widgets.dart';

class BouncingWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scale;

  const BouncingWidget({
    required this.child,
    super.key,
    required this.onPressed,
    this.scale = 0.9,
  });

  @override
  createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget> with SingleTickerProviderStateMixin {
  late Animation<double> _scale;
  late AnimationController _controller;
  bool _isMove = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 50));
    _scale =
        Tween<double>(begin: 1.0, end: widget.scale).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (DragDownDetails event) {
        _isMove = false;
        _controller.forward();
      },
      onPanCancel: () {
        _controller.reverse();
      },
      onPanUpdate: (DragUpdateDetails event) {
        if (event.globalPosition.distance > 3) {
          _isMove = true;
          _controller.reverse();
        }
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails event) {
        if (event.globalPosition.distance > 3) {
          _isMove = true;
          _controller.reverse();
        }
      },
      onTap: () {
        _controller.reverse();
        if (!_isMove) widget.onPressed();
        _isMove = false;
      },
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
