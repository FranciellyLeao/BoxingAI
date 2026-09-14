import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/vision_constants.dart';
import '../../../../core/utils/pose_math_utils.dart';
import '../../domain/entities/body_pose.dart';
import '../../domain/entities/defense_metrics.dart';
import '../../domain/entities/pose_landmark.dart';

/// Renderizador Volumétrico do Personagem/Avatar 3D Cyber-Boxing.
/// Substitui traços 2D simples por um Robô/Manequim 3D com iluminação especular, z-buffer e luvas 3D.
class CyberAvatar3DPainter extends CustomPainter {
  final BodyPose? pose;
  final bool isFrontCamera;
  final bool isArmExtended;
  final DefenseType activeDefenseType;

  CyberAvatar3DPainter({
    required this.pose,
    this.isFrontCamera = true,
    this.isArmExtended = false,
    this.activeDefenseType = DefenseType.none,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pose == null || pose!.imageWidth == 0 || pose!.imageHeight == 0) return;

    final double scaleX = size.width / pose!.imageWidth;
    final double scaleY = size.height / pose!.imageHeight;

    // Função para converter coordenada da imagem para Offset da tela com espelhamento da câmera frontal
    Offset projectPoint(PoseLandmark landmark) {
      double x = landmark.x * scaleX;
      double y = landmark.y * scaleY;
      if (isFrontCamera) {
        x = size.width - x;
      }
      return Offset(x, y);
    }

    final bool isDefending = activeDefenseType != DefenseType.none;

    // 1. DESENHA ESCUDO DE FORÇA CYBER QUANDO O ATLETA ESQUIVA (SLIP/DUCK)
    if (isDefending && pose!.leftShoulder != null && pose!.rightShoulder != null) {
      final pLeftS = projectPoint(pose!.leftShoulder!);
      final pRightS = projectPoint(pose!.rightShoulder!);
      final Offset center = Offset((pLeftS.dx + pRightS.dx) / 2, (pLeftS.dy + pRightS.dy) / 2 - 30);

      final Paint shieldPaint = Paint()
        ..color = CyberBoxingTheme.neonCyan.withOpacity(0.35)
        ..style = PaintingStyle.fill;

      final Paint shieldBorder = Paint()
        ..color = CyberBoxingTheme.neonCyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawOval(
        Rect.fromCenter(center: center, width: 180, height: 220),
        shieldPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 180, height: 220),
        shieldBorder,
      );
    }

    // 2. ORDENAÇÃO DE PROFUNDIDADE Z (Z-Sorting) PARA O ALGORITMO DO PINTOR
    final List<_RenderElement> elements = [];

    // Peitoral / Tronco 3D
    if (pose!.leftShoulder != null && pose!.rightShoulder != null) {
      final pLeftS = projectPoint(pose!.leftShoulder!);
      final pRightS = projectPoint(pose!.rightShoulder!);
      final double avgZ = (pose!.leftShoulder!.z + pose!.rightShoulder!.z) / 2;

      elements.add(_RenderElement(
        z: avgZ,
        draw: () => _draw3DTorso(canvas, pLeftS, pRightS, isDefending),
      ));

      // Cabeça 3D
      final Offset headCenter = Offset((pLeftS.dx + pRightS.dx) / 2, (pLeftS.dy + pRightS.dy) / 2 - 50);
      elements.add(_RenderElement(
        z: avgZ - 10,
        draw: () => _draw3DHead(canvas, headCenter, isDefending),
      ));
    }

    // Braço Esquerdo (Ombro -> Cotovelo -> Punho)
    if (pose!.hasValidLeftArm(VisionConstants.minLandmarkConfidence)) {
      final pS = projectPoint(pose!.leftShoulder!);
      final pE = projectPoint(pose!.leftElbow!);
      final pW = projectPoint(pose!.leftWrist!);

      elements.add(_RenderElement(
        z: pose!.leftElbow!.z,
        draw: () => _draw3DLimb(canvas, pS, pE, isLeft: true),
      ));
      elements.add(_RenderElement(
        z: pose!.leftWrist!.z - 20, // Traz a luva para a frente no Z
        draw: () => _draw3DGlove(canvas, pW, isLeft: true, isExtended: isArmExtended),
      ));
    }

    // Braço Direito (Ombro -> Cotovelo -> Punho)
    if (pose!.hasValidRightArm(VisionConstants.minLandmarkConfidence)) {
      final pS = projectPoint(pose!.rightShoulder!);
      final pE = projectPoint(pose!.rightElbow!);
      final pW = projectPoint(pose!.rightWrist!);

      elements.add(_RenderElement(
        z: pose!.rightElbow!.z,
        draw: () => _draw3DLimb(canvas, pS, pE, isLeft: false),
      ));
      elements.add(_RenderElement(
        z: pose!.rightWrist!.z - 20,
        draw: () => _draw3DGlove(canvas, pW, isLeft: false, isExtended: isArmExtended),
      ));
    }

    // Ordena do ponto mais distante (Z maior) para o mais próximo (Z menor)
    elements.sort((a, b) => b.z.compareTo(a.z));

    for (final element in elements) {
      element.draw();
    }
  }

  /// Desenha a Cabeça 3D do Robô Avatar com Visor Neon.
  void _draw3DHead(Canvas canvas, Offset center, bool isDefending) {
    final Color mainColor = isDefending ? VisionConstants.skeletonColorNormal : VisionConstants.keypointColorLeft;

    final Paint headPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, mainColor, Colors.black87],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 28));

    canvas.drawCircle(center, 26, headPaint);

    // Visor futurista do capacete
    final Paint visorPaint = Paint()
      ..color = isDefending ? VisionConstants.skeletonColorNormal : Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy - 2), width: 32, height: 10),
        const Radius.circular(5),
      ),
      visorPaint,
    );
  }

  /// Desenha a Placa de Armadura do Peitoral/Tronco 3D.
  void _draw3DTorso(Canvas canvas, Offset leftS, Offset rightS, bool isDefending) {
    final Path torsoPath = Path()
      ..moveTo(leftS.dx, leftS.dy)
      ..lineTo(rightS.dx, rightS.dy)
      ..lineTo(rightS.dx - 15, rightS.dy + 90)
      ..lineTo(leftS.dx + 15, leftS.dy + 90)
      ..close();

    final Paint torsoPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          isDefending ? VisionConstants.skeletonColorNormal : VisionConstants.keypointColorRight.withOpacity(0.8),
          Colors.black87,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(torsoPath.getBounds());

    canvas.drawPath(torsoPath, torsoPaint);

    final Paint borderPaint = Paint()
      ..color = isDefending ? Colors.white : VisionConstants.skeletonColorNormal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(torsoPath, borderPaint);
  }

  /// Desenha um Membro 3D Cilíndrico Volumétrico (Bíceps/Antebraço).
  void _draw3DLimb(Canvas canvas, Offset start, Offset end, {required bool isLeft}) {
    final Color color = isLeft ? VisionConstants.keypointColorLeft : VisionConstants.keypointColorRight;

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, linePaint);
    canvas.drawLine(start, end, corePaint);
  }

  /// Desenha a Luva de Boxe Volumétrica 3D com Brilho Pulsante.
  void _draw3DGlove(Canvas canvas, Offset center, {required bool isLeft, required bool isExtended}) {
    final Color gloveColor = isExtended
        ? VisionConstants.skeletonColorExtended
        : (isLeft ? VisionConstants.keypointColorLeft : VisionConstants.keypointColorRight);

    final double radius = isExtended ? 22.0 : 16.0;

    final Paint glovePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, gloveColor, Colors.black],
        stops: const [0.1, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final Paint glowPaint = Paint()
      ..color = gloveColor.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, radius + 4, glowPaint);
    canvas.drawCircle(center, radius, glovePaint);
  }

  @override
  bool shouldRepaint(covariant CyberAvatar3DPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.isArmExtended != isArmExtended ||
        oldDelegate.activeDefenseType != activeDefenseType ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}

class _RenderElement {
  final double z;
  final VoidCallback draw;

  _RenderElement({required this.z, required this.draw});
}
