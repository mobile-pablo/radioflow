import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

class RfEqualizer extends StatefulWidget {
  const RfEqualizer({
    super.key,
    this.barCount = 24,
    this.playing = true,
    this.color = AppColors.accent,
    this.spacing = 3,
  });

  final int barCount;
  final bool playing;
  final Color color;
  final double spacing;

  @override
  State<RfEqualizer> createState() => _RfEqualizerState();
}

class _RfEqualizerState extends State<RfEqualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<double> _phases;

  @override
  void initState() {
    super.initState();
    final random = math.Random(7);
    _phases = List<double>.generate(
      widget.barCount,
      (_) => random.nextDouble() * math.pi * 2,
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(RfEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.playing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _EqualizerPainter(
          t: _controller.value,
          phases: _phases,
          playing: widget.playing,
          color: widget.color,
          spacing: widget.spacing,
        ),
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter({
    required this.t,
    required this.phases,
    required this.playing,
    required this.color,
    required this.spacing,
  });

  final double t;
  final List<double> phases;
  final bool playing;
  final Color color;
  final double spacing;

  static const double _idle = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    final count = phases.length;
    final barWidth = (size.width - spacing * (count - 1)) / count;
    final paint = Paint()..color = color;

    for (var i = 0; i < count; i++) {
      final level = playing
          ? (0.5 + 0.5 * math.sin(t * 2 * math.pi + phases[i]))
                .clamp(_idle, 1.0)
          : _idle;
      final barHeight = size.height * level;
      final x = i * (barWidth + spacing);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_EqualizerPainter old) =>
      old.t != t || old.playing != playing || old.color != color;
}
