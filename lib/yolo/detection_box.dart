import 'dart:ui';

class DetectionBox {
  final Rect rect;
  final double confidence;
  final int classId;

  DetectionBox({
    required this.rect,
    required this.confidence,
    required this.classId,
  });
}
