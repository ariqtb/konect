import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double notchRadius;
  final double notchRatio; // Ratio from top (0.0 to 1.0)
  final Color backgroundColor;
  final Color borderColor;

  const TicketCard({
    super.key,
    required this.child,
    this.borderRadius = 12.0,
    this.notchRadius = 10.0,
    this.notchRatio = 0.5,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFF1F5F9), // slate-100
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TicketPainter(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderRadius: borderRadius,
        notchRadius: notchRadius,
        notchRatio: notchRatio,
      ),
      child: child,
    );
  }
}

class TicketPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double notchRadius;
  final double notchRatio;

  TicketPainter({
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 12.0,
    this.notchRadius = 10.0,
    required this.notchRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final paintBorder = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final double w = size.width;
    final double h = size.height;
    final double cy = h * notchRatio;

    final path = Path();
    
    // Top-Left corner to Top-Right
    path.moveTo(borderRadius, 0);
    path.lineTo(w - borderRadius, 0);
    path.quadraticBezierTo(w, 0, w, borderRadius);

    // Down to right notch
    path.lineTo(w, cy - notchRadius);
    path.arcToPoint(
      Offset(w, cy + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Down to Bottom-Right corner
    path.lineTo(w, h - borderRadius);
    path.quadraticBezierTo(w, h, w - borderRadius, h);
    
    // Left to Bottom-Left corner
    path.lineTo(borderRadius, h);
    path.quadraticBezierTo(0, h, 0, h - borderRadius);
    
    // Up to left notch
    path.lineTo(0, cy + notchRadius);
    path.arcToPoint(
      Offset(0, cy - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Up to Top-Left corner
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    
    path.close();

    // Draw background
    canvas.drawPath(path, paintBg);
    
    // Draw border
    canvas.drawPath(path, paintBorder);

    // Draw dashed line across the notches
    final paintDashed = Paint()
      ..color = const Color(0xFFCBD5E1) // Slate-300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = notchRadius;
    final double endX = w - notchRadius;
    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, cy),
        Offset(startX + dashWidth, cy),
        paintDashed,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
