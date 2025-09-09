import 'package:flutter/material.dart';
import 'detection_box.dart';

class BoxOverlayPainter extends CustomPainter {
  final List<DetectionBox> boxes;
  final List<String>? labels; // ✅ 선택적 라벨 리스트

  BoxOverlayPainter(this.boxes, {this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    final textStyle = TextStyle(
      color: Colors.red,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.white,
    );

    for (final box in boxes) {
      final scaledRect = Rect.fromLTRB(
        box.rect.left,
        box.rect.top,
        box.rect.right,
        box.rect.bottom,
      );

      canvas.drawRect(scaledRect, paint);

      if (labels != null && box.classId < labels!.length) {
        final textSpan = TextSpan(
          text:
              '${labels![box.classId]} (${(box.confidence * 100).toStringAsFixed(1)}%)',
          style: textStyle,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset(scaledRect.left, scaledRect.top - 20));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
