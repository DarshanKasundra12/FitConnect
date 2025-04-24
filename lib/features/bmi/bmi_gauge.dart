import 'package:flutter/material.dart';
import 'dart:math' as math;

class BMIGauge extends StatefulWidget {
  final double bmi;

  const BMIGauge({
    super.key,
    required this.bmi,
  });

  @override
  State<BMIGauge> createState() => _BMIGaugeState();
}

class _BMIGaugeState extends State<BMIGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    // Calculate the position on the gauge (0 to 1)
    final position = _calculateGaugePosition(widget.bmi);
    
    _animation = Tween<double>(
      begin: 0.0,
      end: position,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(BMIGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      final position = _calculateGaugePosition(widget.bmi);
      _animation = Tween<double>(
        begin: _animation.value,
        end: position,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Calculate position on the gauge (0 to 1)
  double _calculateGaugePosition(double bmi) {
    // BMI range for the gauge: 10 to 40
    const minBmi = 10.0;
    const maxBmi = 40.0;
    
    // Clamp BMI value to the range
    final clampedBmi = bmi.clamp(minBmi, maxBmi);
    
    // Calculate position (0 to 1)
    return (clampedBmi - minBmi) / (maxBmi - minBmi);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _BMIGaugePainter(
            value: _animation.value,
            bmi: widget.bmi,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BMIGaugePainter extends CustomPainter {
  final double value; // 0 to 1
  final double bmi;

  _BMIGaugePainter({
    required this.value,
    required this.bmi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) * 0.8;
    
    // Draw the gauge background
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    // Draw the gauge arc (180 degrees)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start angle (180 degrees)
      math.pi, // Sweep angle (180 degrees)
      false,
      bgPaint,
    );
    
    // Draw the colored sections
    _drawColoredSections(canvas, center, radius);
    
    // Draw the gauge value
    final valuePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    
    // Calculate the angle based on the value (0 to 1)
    final angle = math.pi + (math.pi * value);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start angle (180 degrees)
      (angle - math.pi), // Sweep angle
      false,
      valuePaint,
    );
    
    // Draw the needle
    _drawNeedle(canvas, center, radius, angle);
    
    // Draw the labels
    _drawLabels(canvas, center, radius);
  }
  
  void _drawColoredSections(Canvas canvas, Offset center, double radius) {
    // Underweight section (blue)
    final underweightPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    // Normal section (green)
    final normalPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    // Overweight section (orange)
    final overweightPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    // Obese section (red)
    final obesePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    
    // Draw the sections
    // Underweight: 10-18.5 BMI (approximately 0-0.28 of the gauge)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start angle (180 degrees)
      math.pi * 0.28, // Sweep angle
      false,
      underweightPaint,
    );
    
    // Normal: 18.5-25 BMI (approximately 0.28-0.5 of the gauge)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi + (math.pi * 0.28), // Start angle
      math.pi * 0.22, // Sweep angle
      false,
      normalPaint,
    );
    
    // Overweight: 25-30 BMI (approximately 0.5-0.67 of the gauge)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi + (math.pi * 0.5), // Start angle
      math.pi * 0.17, // Sweep angle
      false,
      overweightPaint,
    );
    
    // Obese: 30-40 BMI (approximately 0.67-1.0 of the gauge)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi + (math.pi * 0.67), // Start angle
      math.pi * 0.33, // Sweep angle
      false,
      obesePaint,
    );
  }
  
  void _drawNeedle(Canvas canvas, Offset center, double radius, double angle) {
    final needlePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    
    // Calculate the needle point
    final needleLength = radius * 0.8;
    final needlePoint = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );
    
    // Draw the needle line
    canvas.drawLine(
      center,
      needlePoint,
      Paint()
        ..color = Colors.grey.shade800
        ..strokeWidth = 3,
    );
    
    // Draw the needle circle
    canvas.drawCircle(
      center,
      radius * 0.08,
      needlePaint,
    );
    
    // Draw the BMI value
    final textPainter = TextPainter(
      text: TextSpan(
        text: bmi.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - radius * 0.3,
      ),
    );
  }
  
  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final labelRadius = radius * 1.1;
    
    // BMI value labels
    final labels = [
      {'value': '10', 'angle': math.pi},
      {'value': '18.5', 'angle': math.pi + (math.pi * 0.28)},
      {'value': '25', 'angle': math.pi + (math.pi * 0.5)},
      {'value': '30', 'angle': math.pi + (math.pi * 0.67)},
      {'value': '40', 'angle': math.pi * 2},
    ];
    
    for (final label in labels) {
      final angle = label['angle'] as double;
      final value = label['value'] as String;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);
      
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );
    }
    
    // Category labels
    final categories = [
      {'label': 'Underweight', 'angle': math.pi + (math.pi * 0.14)},
      {'label': 'Normal', 'angle': math.pi + (math.pi * 0.39)},
      {'label': 'Overweight', 'angle': math.pi + (math.pi * 0.585)},
      {'label': 'Obese', 'angle': math.pi + (math.pi * 0.835)},
    ];
    
    for (final category in categories) {
      final angle = category['angle'] as double;
      final label = category['label'] as String;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      final x = center.dx + (radius * 0.6) * math.cos(angle);
      final y = center.dy + (radius * 0.6) * math.sin(angle);
      
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_BMIGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.bmi != bmi;
  }
}
