import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:circuit_stem/models/circuit_component.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/theme.dart';

class CircuitComponentWidget extends StatelessWidget {
  final CircuitComponent component;
  final double size;
  final VoidCallback? onTap;
  final bool isPreview;

  const CircuitComponentWidget({
    Key? key,
    required this.component,
    required this.size,
    this.onTap,
    this.isPreview = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: CustomPaint(
          painter: _ComponentPainter(
            component: component,
            isDark: isDark,
            size: size,
            isPreview: isPreview,
          ),
        ),
      ),
    );
  }
}

class _ComponentPainter extends CustomPainter {
  final CircuitComponent component;
  final bool isDark;
  final double size;
  final bool isPreview;

  _ComponentPainter({
    required this.component,
    required this.isDark,
    required this.size,
    required this.isPreview,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.1;
  // ...existing code...
    
    final wireColor = component.isPowered
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark ? DarkModeColors.wireUnpowered : LightModeColors.wireUnpowered);

    final componentColor = component.isPowered
        ? (isDark ? DarkModeColors.componentActive : LightModeColors.componentActive)
        : (isDark ? DarkModeColors.componentInactive : LightModeColors.componentInactive);

    final paint = Paint()
      ..color = wireColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

        switch (component.type) {
          case ComponentType.wireStraight:
            _paintWire(canvas, size, paint);
            break;
          case ComponentType.wireCorner:
            _paintWireCorner(canvas, size, paint);
            break;
          case ComponentType.wireT:
            _paintWireTJunction(canvas, size, paint, wireColor);
            break;
          case ComponentType.wireLong:
            _paintWireCross(canvas, size, paint);
            break;
          case ComponentType.battery:
            _paintBattery(canvas, size, paint, componentColor);
            break;
          case ComponentType.bulb:
            _paintBulb(canvas, size, paint, componentColor);
            break;
          case ComponentType.sw:
            _paintSwitch(canvas, size, paint, componentColor);
            break;
          case ComponentType.resistor:
            _paintResistor(canvas, size, paint, componentColor);
            break;
          case ComponentType.blocked:
            // Draw X or blocked indicator
            break;
          case ComponentType.timer:
            // Draw timer indicator
            break;
          case ComponentType.custom:
            // Handle custom types
            break;
        }
  }

  void _paintWire(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    
    switch (component.direction) {
      case Direction.up:
      case Direction.down:
        canvas.drawLine(
          Offset(center.dx, 0),
          Offset(center.dx, size.height),
          paint,
        );
        break;
      case Direction.left:
      case Direction.right:
        canvas.drawLine(
          Offset(0, center.dy),
          Offset(size.width, center.dy),
          paint,
        );
        break;
    }
  }

  void _paintWireCorner(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    
    switch (component.direction) {
      case Direction.right: // ↱ from bottom to right
        canvas.drawLine(center, Offset(size.width, center.dy), paint);
        canvas.drawLine(center, Offset(center.dx, size.height), paint);
        break;
      case Direction.down: // ↲ from left to down
        canvas.drawLine(Offset(0, center.dy), center, paint);
        canvas.drawLine(center, Offset(center.dx, size.height), paint);
        break;
      case Direction.left: // ↰ from top to left
        canvas.drawLine(Offset(0, center.dy), center, paint);
        canvas.drawLine(center, Offset(center.dx, 0), paint);
        break;
      case Direction.up: // ↳ from right to up
        canvas.drawLine(center, Offset(size.width, center.dy), paint);
        canvas.drawLine(center, Offset(center.dx, 0), paint);
        break;
    }
  }
  
  void _paintWireTJunction(Canvas canvas, Size size, Paint paint, Color color) {
    final center = Offset(size.width / 2, size.height / 2);
    
    switch (component.direction) {
      case Direction.up:
        canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
        canvas.drawLine(center, Offset(center.dx, 0), paint);
        break;
      case Direction.right:
        canvas.drawLine(center, Offset(size.width, center.dy), paint);
        canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
        break;
      case Direction.down:
        canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
        canvas.drawLine(center, Offset(center.dx, size.height), paint);
        break;
      case Direction.left:
        canvas.drawLine(Offset(0, center.dy), center, paint);
        canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
        break;
    }
  }

  void _paintWireCross(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
  }

  void _paintBattery(Canvas canvas, Size size, Paint paint, Color color) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.6,
      height: size.height * 0.3,
    );
    
    paint.style = PaintingStyle.fill;
    paint.color = color;
    
    canvas.drawRect(rect, paint);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.05;
    canvas.drawRect(rect, paint);

    final plusSignPath = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.2)
      ..lineTo(center.dx, center.dy + size.height * 0.2)
      ..moveTo(center.dx - size.width * 0.2, center.dy)
      ..lineTo(center.dx + size.width * 0.2, center.dy);
    
    canvas.drawPath(plusSignPath, paint);
  }

  void _paintBulb(Canvas canvas, Size size, Paint paint, Color color) {
    if (component.isPowered) {
      // Draw glowing effect
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.1);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.4, glowPaint);
    }

    // Draw bulb shape
    final bulbPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..addArc(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.45),
          width: size.width * 0.4,
          height: size.height * 0.5,
        ),
        math.pi,
        -math.pi,
      );

    paint.color = color;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(bulbPath, paint);
  }

  void _paintSwitch(Canvas canvas, Size size, Paint paint, Color color) {
    final center = Offset(size.width / 2, size.height / 2);
    final armEnd = component.isSwitchClosed
        ? Offset(size.width * 0.8, size.height * 0.2)
        : Offset(size.width * 0.8, size.height * 0.8);

    // Draw fixed contact point
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.5), size.width * 0.05, paint);
    
    // Draw moving arm
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.5), armEnd, paint);
    
    if (!component.isSwitchClosed) {
      // Draw open contact point
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.8), size.width * 0.05, paint);
    }
  }

  void _paintResistor(Canvas canvas, Size size, Paint paint, Color color) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width * 0.2, size.height / 2)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height / 2)
      ..lineTo(size.width, size.height / 2);

    paint.color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ComponentPainter oldDelegate) {
    return component.isPowered != oldDelegate.component.isPowered ||
           component.isSwitchClosed != oldDelegate.component.isSwitchClosed ||
           isDark != oldDelegate.isDark;
  }
}
