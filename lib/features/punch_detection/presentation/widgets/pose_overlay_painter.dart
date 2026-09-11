import 'package:flutter/material.dart';

import '../../../../core/constants/vision_constants.dart';
import '../../domain/entities/body_pose.dart';
import '../../domain/entities/pose_landmark.dart';

/// Painter otimizado para desenhar o esqueleto vetorial (ombros e braços) sobre o preview da câmera.
class PoseOverlayPainter extends CustomPainter {
  final BodyPose? pose;
  final bool isFrontCamera;
  final bool isArmExtended;

  PoseOverlayPainter({
    required this.pose,
    this.isFrontCamera = true,
    this.isArmExtended = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pose == null || pose!.imageWidth == 0 || pose!.imageHeight == 0) return;

    final double scaleX = size.width / pose!.imageWidth;
    final double scaleY = size.height / pose!.imageHeight;

    // Configuração dos Pincéis (Paints)
    final Paint linePaintNormal = Paint()
      ..color = isArmExtended ? VisionConstants.skeletonColorExtended : VisionConstants.skeletonColorNormal
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint jointPaintLeft = Paint()
      ..color = VisionConstants.keypointColorLeft
      ..style = PaintingStyle.fill;

    final Paint jointPaintRight = Paint()
      ..color = VisionConstants.keypointColorRight
      ..style = PaintingStyle.fill;

    final Paint jointGlowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Função interna para converter a coordenada da imagem para a tela com espelhamento da Câmera Frontal
    Offset translateX(PoseLandmark landmark) {
      double x = landmark.x * scaleX;
      double y = landmark.y * scaleY;

      if (isFrontCamera) {
        x = size.width - x; // Espelha horizontalmente para criar o efeito de espelho natural
      }
      return Offset(x, y);
    }

    // 1. Desenha Conexão dos Ombro (Ombro Esquerdo <-> Ombro Direito)
    if (pose!.leftShoulder != null && pose!.rightShoulder != null) {
      final pLeft = translateX(pose!.leftShoulder!);
      final pRight = translateX(pose!.rightShoulder!);
      canvas.drawLine(pLeft, pRight, linePaintNormal);
    }

    // 2. Desenha Braço Esquerdo (Ombro -> Cotovelo -> Punho)
    if (pose!.hasValidLeftArm(VisionConstants.minLandmarkConfidence)) {
      final pShoulder = translateX(pose!.leftShoulder!);
      final pElbow = translateX(pose!.leftElbow!);
      final pWrist = translateX(pose!.leftWrist!);

      canvas.drawLine(pShoulder, pElbow, linePaintNormal);
      canvas.drawLine(pElbow, pWrist, linePaintNormal);

      // Pontos das articulações
      _drawJoint(canvas, pShoulder, jointPaintLeft, jointGlowPaint);
      _drawJoint(canvas, pElbow, jointPaintLeft, jointGlowPaint);
      _drawJoint(canvas, pWrist, jointPaintLeft, jointGlowPaint, radius: 10.0);
    }

    // 3. Desenha Braço Direito (Ombro -> Cotovelo -> Punho)
    if (pose!.hasValidRightArm(VisionConstants.minLandmarkConfidence)) {
      final pShoulder = translateX(pose!.rightShoulder!);
      final pElbow = translateX(pose!.rightElbow!);
      final pWrist = translateX(pose!.rightWrist!);

      canvas.drawLine(pShoulder, pElbow, linePaintNormal);
      canvas.drawLine(pElbow, pWrist, linePaintNormal);

      // Pontos das articulações
      _drawJoint(canvas, pShoulder, jointPaintRight, jointGlowPaint);
      _drawJoint(canvas, pElbow, jointPaintRight, jointGlowPaint);
      _drawJoint(canvas, pWrist, jointPaintRight, jointGlowPaint, radius: 10.0);
    }
  }

  void _drawJoint(Canvas canvas, Offset offset, Paint fillPaint, Paint strokePaint, {double radius = 7.0}) {
    canvas.drawCircle(offset, radius, fillPaint);
    canvas.drawCircle(offset, radius, strokePaint);
  }

  @override
  bool shouldRepaint(covariant PoseOverlayPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.isArmExtended != isArmExtended ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}
