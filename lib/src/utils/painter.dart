import 'package:flutter/material.dart';
import 'package:flutter_confetti/src/utils/glue.dart';

class Painter extends CustomPainter {
  final AnimationController? animationController;
  final List<Glue> glueList;

  Painter({required this.glueList, this.animationController})
      : super(repaint: animationController);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < glueList.length; i++) {
      final glue = glueList[i];
      final physics = glue.physics;

      if (!physics.finished) {
        physics.update();
        glue.particle.paint(physics: physics, canvas: canvas);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Painter oldDelegate) {
    return true;
  }
}
