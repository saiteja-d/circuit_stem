import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stemcir/models/circuit_component.dart';
import 'package:stemcir/theme.dart';

class CircuitComponentWidget extends StatelessWidget {
  final CircuitComponent component;
  final double size;
  final VoidCallback? onTap;
  final bool isPreview;
  
  const CircuitComponentWidget({
    super.key,
    required this.component,
    this.size = 40.0,
    this.onTap,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ComponentPainter(
            component: component,
            isDark: Theme.of(context).brightness == Brightness.dark,
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
  final bool isPreview;
  
  _ComponentPainter({
    required this.component,
    required this.isDark,
    required this.isPreview,
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
    final wireColor = component.isPowered 
        ? (isDark ? DarkModeColors.wirePowered : LightModeColors.wirePowered)
        : (isDark ? DarkModeColors.wireUnpowered : LightModeColors.wireUnpowered);
    
    final componentColor = component.isPowered 
        ? (isDark ? DarkModeColors.componentActive : LightModeColors.componentActive)
        : (isDark ? DarkModeColors.componentInactive : LightModeColors.componentInactive);

    switch (component.type) {
      case ComponentType.wire:
        _paintWire(canvas, size, paint, wireColor);
        break;
      case ComponentType.wireCorner:
        _paintWireCorner(canvas, size, paint, wireColor);
        break;
      case ComponentType.wireTJunction:
        _paintWireTJunction(canvas, size, paint, wireColor);
        break;
      case ComponentType.wireCross:
        _paintWireCross(canvas, size, paint, wireColor);
        break;
      case ComponentType.battery:
        _paintBattery(canvas, size, paint, fillPaint, componentColor, center, radius);
        break;
      case ComponentType.bulb:
        _paintBulb(canvas, size, paint, fillPaint, componentColor, center, radius);
        break;
      case ComponentType.circuitSwitch:
        _paintSwitch(canvas, size, paint, componentColor, center, radius);
        break;
      case ComponentType.resistor:
        _paintResistor(canvas, size, paint, componentColor, center);
        break;
    }
  }
  
  void _paintWire(Canvas canvas, Size size, Paint paint, Color color) {
    paint.color = color;
    paint.strokeWidth = 3.0;
    
    // Draw straight wire based on direction
    switch (component.direction) {
      case Direction.up:
      case Direction.down:
        canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          paint,
        );
        break;
      case Direction.left:
      case Direction.right:
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          paint,
        );
        break;
    }
  }
  
  void _paintWireCorner(Canvas canvas, Size size, Paint paint, Color color) {
    paint.color = color;
    paint.strokeWidth = 3.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw L-shaped corner based on direction
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
    paint.color = color;
    paint.strokeWidth = 3.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw T-junction based on direction
    switch (component.direction) {
      case Direction.right: // ⊥ T pointing right
        canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
        canvas.drawLine(center, Offset(size.width, center.dy), paint);
        break;
      case Direction.down: // ⊤ T pointing down
        canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
        canvas.drawLine(center, Offset(center.dx, size.height), paint);
        break;
      case Direction.left: // ⊢ T pointing left
        canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
        canvas.drawLine(Offset(0, center.dy), center, paint);
        break;
      case Direction.up: // ⊥ T pointing up
        canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
        canvas.drawLine(center, Offset(center.dx, 0), paint);
        break;
    }
  }
  
  void _paintWireCross(Canvas canvas, Size size, Paint paint, Color color) {
    paint.color = color;
    paint.strokeWidth = 3.0;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw cross junction (+ shape)
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
  }
  
  void _paintBattery(Canvas canvas, Size size, Paint paint, Paint fillPaint, 
                    Color color, Offset center, double radius) {
    paint.color = color;
    fillPaint.color = color;
    
    // Draw battery terminals
    final terminalHeight = size.height * 0.6;
    final terminalWidth = size.width * 0.15;
    
    // Positive terminal (taller)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.2, center.dy),
        width: terminalWidth,
        height: terminalHeight,
      ),
      fillPaint,
    );
    
    // Negative terminal (shorter)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx + size.width * 0.2, center.dy),
        width: terminalWidth,
        height: terminalHeight * 0.6,
      ),
      fillPaint,
    );
    
    // Add + and - symbols
    final textPainter = TextPainter(
      text: TextSpan(
        text: '+',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - size.width * 0.3, center.dy - 6));
    
    textPainter.text = TextSpan(
      text: '−',
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx + size.width * 0.1, center.dy - 6));
  }
  
  void _paintBulb(Canvas canvas, Size size, Paint paint, Paint fillPaint,
                 Color color, Offset center, double radius) {
    // Draw bulb circle
    paint.color = color;
    canvas.drawCircle(center, radius, paint);
    
    if (component.isPowered) {
      // Fill with light color when powered
      fillPaint.color = color.withValues(alpha: 0.3);
      canvas.drawCircle(center, radius, fillPaint);
      
      // Add light rays
      paint.strokeWidth = 1.0;
      for (int i = 0; i < 8; i++) {
        final angle = (i * 45) * (3.14159 / 180);
        final start = Offset(
          center.dx + (radius + 2) * cos(angle),
          center.dy + (radius + 2) * sin(angle),
        );
        final end = Offset(
          center.dx + (radius + 8) * cos(angle),
          center.dy + (radius + 8) * sin(angle),
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
    final armEnd = component.isSwitchClosed 
        ? Offset(center.dx + radius, center.dy)
        : Offset(center.dx + radius * 0.5, center.dy - radius * 0.8);
    
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      armEnd,
      paint,
    );
    
    // Draw switch indicator
    if (!component.isSwitchClosed) {
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
    final segments = 6;
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
  
  double cos(double radians) => math.cos(radians);
  double sin(double radians) => math.sin(radians);
  
  @override
  bool shouldRepaint(_ComponentPainter oldDelegate) {
    return component.isPowered != oldDelegate.component.isPowered ||
           component.isSwitchClosed != oldDelegate.component.isSwitchClosed ||
           component.direction != oldDelegate.component.direction;
  }
}