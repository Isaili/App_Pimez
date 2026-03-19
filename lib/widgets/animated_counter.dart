import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final double value;
  final Duration duration;
  final TextStyle? style;
  final String Function(double) formatter;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 500),
    this.style,
    required this.formatter,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _startAnimation();
  }

  void _startAnimation() {
    _animation.addListener(() {
      setState(() {
        _displayValue = _animation.value * widget.value;
      });
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _startAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.formatter(_displayValue),
      style: widget.style,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}