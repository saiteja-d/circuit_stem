import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/common/theme.dart';
import 'package:circuit_stem/common/constants.dart';

class CircuitComponentPainter extends CustomPainter {
  final ComponentModel component;
  final bool isPowered;
  final bool isSwitchClosed;
  final bool isDark;
  final CellOffset partOffset; // Offset of this part within the component's shape

  CircuitComponentPainter({
    required this.component,
    required this.isPowered,
    required this.isSwitchClosed,
    required this.isDark,
    required this.partOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final fillPaint = Paint()..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    
    // Get colors based on theme and power state
    final wireColor = isPowered 
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark ? DarkModeColors.wireUnpowered : LightModeColors.wireUnpowered);
    
    final componentColor = isPowered 
        ? (isDark ? DarkModeColors.componentActive : LightModeColors.componentActive)
        : (isDark ? DarkModeColors.componentInactive : LightModeColors.componentInactive);

    // Apply rotation to the canvas for the current part
    canvas.save();
    final rotationAngle = (component.rotation % 360) * (math.pi / 180);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    switch (component.type) {
      case ComponentType.wireStraight:
        _paintWireStraight(canvas, size, paint, wireColor);
        break;
      case ComponentType.wireCorner:
        _paintWireCorner(canvas, size, paint, wireColor);
        break;
      case ComponentType.wireT:
        _paintWireTJunction(canvas, size, paint, wireColor);
        break;
      case ComponentType.wireLong:
        // For wireLong, we need to determine if this part is a straight or corner segment
        // This is a simplification; a more robust solution would involve analyzing shapeOffsets
        // For now, assume wireLong parts are straight segments.
        _paintWireStraight(canvas, size, paint, wireColor);
        break;
      case ComponentType.battery:
        _paintBattery(canvas, size, paint, fillPaint, componentColor, center, radius);
        break;
      case ComponentType.bulb:
        _paintBulb(canvas, size, paint, fillPaint, componentColor, center, radius);
        break;
      case ComponentType.sw:
        _paintSwitch(canvas, size, paint, componentColor, center, radius);
        break;
      case ComponentType.resistor:
        _paintResistor(canvas, size, paint, componentColor, center);
        break;
      case ComponentType.timer:
        _paintTimer(canvas, size, paint, componentColor, center, radius);
        break;
      case ComponentType.blocked:
        _paintBlocked(canvas, size, paint, componentColor, center, radius);
        break;
    }
    canvas.restore();
  }
  
  void _paintWireStraight(Canvas canvas, Size size, Paint paint, Color color) {
    paint.color = color;
    paint.strokeWidth = 3.0;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }
  
  void _paintWireCorner(Canvas canvas, Size size, Paint paint, Color color) {
    paint.color = color;
    paint.strokeWidth = 3.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw L-shaped corner
    canvas.drawLine(center, Offset(size.width, center.dy), paint);
    canvas.drawLine(center, Offset(center.dx, size.height), paint);
  }
  
  void _paintWireTJunction(Canvas canvas, Size size, Paint paint, Color color) {
    paint.color = color;
    paint.strokeWidth = 3.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw T-junction
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
    canvas.drawLine(center, Offset(size.width, center.dy), paint);
  }
  
  void _paintBattery(Canvas canvas, Size size, Paint paint, Paint fillPaint, 
                    Color color, Offset center, double radius) {
    paint.color = color;
    fillPaint.color = color;
    
    // Draw battery body
    final batteryRect = Rect.fromCenter(center: center, width: size.width * 0.8, height: size.height * 0.4);
    canvas.drawRRect(RRect.fromRectAndRadius(batteryRect, const Radius.circular(4)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(batteryRect, const Radius.circular(4)), paint);

    // Draw terminals
    final terminalHeight = size.height * 0.2;
    final terminalWidth = size.width * 0.1;
    
    // Positive terminal
    canvas.drawRect(
      Rect.fromLTWH(batteryRect.right, center.dy - terminalHeight / 2, terminalWidth, terminalHeight),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(batteryRect.right, center.dy - terminalHeight / 2, terminalWidth, terminalHeight),
      paint,
    );
    
    // Negative terminal
    canvas.drawRect(
      Rect.fromLTWH(batteryRect.left - terminalWidth, center.dy - terminalHeight / 2, terminalWidth, terminalHeight),
      fillPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(batteryRect.left - terminalWidth, center.dy - terminalHeight / 2, terminalWidth, terminalHeight),
      paint,
    );

    // Add + and - symbols
    final textPainterPlus = TextPainter(
      text: TextSpan(
        text: '+',
        style: TextStyle(color: isDark ? DarkModeColors.onPrimary : LightModeColors.onPrimary, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterPlus.layout();
    textPainterPlus.paint(canvas, Offset(batteryRect.right + terminalWidth / 2 - textPainterPlus.width / 2, center.dy - textPainterPlus.height / 2));
    
    final textPainterMinus = TextPainter(
      text: TextSpan(
        text: '−',
        style: TextStyle(color: isDark ? DarkModeColors.onPrimary : LightModeColors.onPrimary, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainterMinus.layout();
    textPainterMinus.paint(canvas, Offset(batteryRect.left - terminalWidth / 2 - textPainterMinus.width / 2, center.dy - textPainterMinus.height / 2));
  }
  
  void _paintBulb(Canvas canvas, Size size, Paint paint, Paint fillPaint,
                 Color color, Offset center, double radius) {
    // Draw bulb circle
    paint.color = color;
    canvas.drawCircle(center, radius, paint);
    
    if (isPowered) {
      // Fill with light color when powered
      fillPaint.color = color.withOpacity(0.3);
      canvas.drawCircle(center, radius, fillPaint);
      
      // Add light rays
      paint.strokeWidth = 1.0;
      for (int i = 0; i < 8; i++) {
        final angle = (i * 45) * (math.pi / 180);
        final start = Offset(
          center.dx + (radius + 2) * math.cos(angle),
          center.dy + (radius + 2) * math.sin(angle),
        );
        final end = Offset(
          center.dx + (radius + 8) * math.cos(angle),
          center.dy + (radius + 8) * math.sin(angle),
        );
        canvas.drawLine(start, end, paint);
      }
    }
    
    // Draw filament
    paint.strokeWidth = 1.0;
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      paint,
    );
  }
  
  void _paintSwitch(Canvas canvas, Size size, Paint paint, Color color,
                   Offset center, double radius) {
    paint.color = color;
    paint.strokeWidth = 2.0;
    
    // Draw switch contacts
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 3, paint);
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 3, paint);
    
    // Draw switch arm
    final armEnd = isSwitchClosed 
        ? Offset(center.dx + radius, center.dy)
        : Offset(center.dx + radius * 0.5, center.dy - radius * 0.8);
    
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      armEnd,
      paint,
    );
    
    // Draw switch indicator
    if (!isSwitchClosed) {
      paint.strokeWidth = 1.0;
      canvas.drawCircle(Offset(center.dx, center.dy - radius), 2, paint);
    }
  }
  
  void _paintResistor(Canvas canvas, Size size, Paint paint, Color color, Offset center) {
    paint.color = color;
    paint.strokeWidth = 2.0;
    
    // Draw resistor zigzag pattern
    final path = Path();
    final width = size.width * 0.6;
    final height = size.height * 0.3;
    const segments = 6;
    final segmentWidth = width / segments;
    
    path.moveTo(center.dx - width / 2, center.dy);
    
    for (int i = 0; i < segments; i++) {
      final x = center.dx - width / 2 + i * segmentWidth + segmentWidth / 2;
      final y = center.dy + (i % 2 == 0 ? -height / 2 : height / 2);
      path.lineTo(x, y);
      path.lineTo(x + segmentWidth / 2, center.dy);
    }
    
    canvas.drawPath(path, paint);
  }

  void _paintTimer(Canvas canvas, Size size, Paint paint, Color color, Offset center, double radius) {
    paint.color = color;
    fillPaint.color = color.withOpacity(0.2);

    // Draw clock face
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, paint);

    // Draw clock hands (simplified)
    paint.strokeWidth = 2.0;
    canvas.drawLine(center, Offset(center.dx, center.dy - radius * 0.6), paint); // Minute hand
    canvas.drawLine(center, Offset(center.dx + radius * 0.4, center.dy), paint); // Hour hand

    // Draw center dot
    canvas.drawCircle(center, 2, paint..style = PaintingStyle.fill);
  }

  void _paintBlocked(Canvas canvas, Size size, Paint paint, Color color, Offset center, double radius) {
    paint.color = color;
    fillPaint.color = color.withOpacity(0.2);

    // Draw a cross or 'X' to indicate blocked
    paint.strokeWidth = 4.0;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);

    // Draw a circle around it
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CircuitComponentPainter oldDelegate) {
    return component.id != oldDelegate.component.id ||
           isPowered != oldDelegate.isPowered ||
           isSwitchClosed != oldDelegate.isSwitchClosed ||
           component.rotation != oldDelegate.component.rotation ||
           isDark != oldDelegate.isDark ||
           partOffset != oldDelegate.partOffset;
  }
}