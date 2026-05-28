import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

class RfLogo extends StatelessWidget {
  const RfLogo({super.key, this.size = 64, this.glow = true});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _RfLogoPainter(glow: glow)),
    );
  }
}

class _RfLogoPainter extends CustomPainter {
  _RfLogoPainter({required this.glow});

  final bool glow;

  static const double _viewBox = 200;
  static const Offset _tip = Offset(165, 80);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _viewBox);

    final wave = Path()
      ..moveTo(30, 110)
      ..cubicTo(40, 78, 70, 78, 90, 105)
      ..cubicTo(105, 124, 122, 130, 140, 116)
      ..cubicTo(154, 105, 162, 96, 168, 86)
      ..cubicTo(162, 102, 152, 120, 138, 130)
      ..cubicTo(116, 145, 92, 142, 76, 122)
      ..cubicTo(60, 102, 46, 102, 38, 122)
      ..close();

    canvas.drawPath(
      wave.shift(const Offset(0, 3)),
      Paint()
        ..color = const Color(0x8C000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawPath(
      wave,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), AppColors.cream, Color(0xFFC9C3B6)],
          stops: [0, 0.5, 1],
        ).createShader(wave.getBounds()),
    );

    canvas.drawPath(
      Path()
        ..moveTo(42, 102)
        ..cubicTo(52, 90, 70, 90, 84, 104),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x99FFFFFF),
    );

    if (glow) {
      canvas.drawCircle(
        _tip,
        28,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xF238E1B0), Color(0x8C38E1B0), Color(0x0038E1B0)],
            stops: [0, 0.4, 1],
          ).createShader(Rect.fromCircle(center: _tip, radius: 28)),
      );
    }
    canvas.drawCircle(_tip, 5, Paint()..color = AppColors.accent);
    canvas.drawCircle(_tip, 2, Paint()..color = const Color(0xFFD6FFF1));
  }

  @override
  bool shouldRepaint(_RfLogoPainter oldDelegate) => oldDelegate.glow != glow;
}
