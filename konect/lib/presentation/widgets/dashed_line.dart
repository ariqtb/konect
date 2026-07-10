import 'package:flutter/material.dart';

class CanvasConnection {
  final Offset start;
  final Offset end;
  final bool isLRoute;

  CanvasConnection({
    required this.start,
    required this.end,
    this.isLRoute = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasConnection &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          isLRoute == other.isLRoute;

  @override
  int get hashCode => start.hashCode ^ end.hashCode ^ isLRoute.hashCode;
}

class DashedLinePainter extends CustomPainter {
  final List<CanvasConnection> connections;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  DashedLinePainter({
    required this.connections,
    this.color = const Color(0xFFD1D1CF),
    this.strokeWidth = 2.0,
    this.dashLength = 6.0,
    this.dashGap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final conn in connections) {
      if (conn.isLRoute) {
        final double x1 = conn.start.dx;
        final double y1 = conn.start.dy;
        final double x2 = conn.end.dx;
        final double y2 = conn.end.dy;

        // Path goes vertically down to y2, then horizontally to x2
        _drawDashedLine(canvas, Offset(x1, y1), Offset(x1, y2), paint);
        _drawDashedLine(canvas, Offset(x1, y2), Offset(x2, y2), paint);
      } else {
        _drawDashedLine(canvas, conn.start, conn.end, paint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = Offset(dx, dy).distance;
    
    if (distance == 0) return;

    final double ux = dx / distance;
    final double uy = dy / distance;

    double drawn = 0.0;
    while (drawn < distance) {
      final double len = (distance - drawn) < dashLength ? (distance - drawn) : dashLength;
      canvas.drawLine(
        Offset(start.dx + ux * drawn, start.dy + uy * drawn),
        Offset(start.dx + ux * (drawn + len), start.dy + uy * (drawn + len)),
        paint,
      );
      drawn += dashLength + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) {
    return oldDelegate.connections != connections ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
