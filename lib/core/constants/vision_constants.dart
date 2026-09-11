import 'package:flutter/material.dart';

/// Constantes globais para visão computacional e thresholds de detecção do soco (Jab).
abstract class VisionConstants {
  /// Ângulo mínimo (em graus) no cotovelo para considerar o braço estendido (Jab).
  static const double jabMinElbowAngleDegrees = 155.0;

  /// Razão mínima entre a distância Ombro-Punho e a soma (Ombro-Cotovelo + Cotovelo-Punho).
  static const double jabMinExtensionRatio = 0.88;

  /// Ângulo de retorno para a posição de guarda (reset da máquina de estados).
  static const double guardResetAngleDegrees = 110.0;

  /// Nível de confiança mínimo para um Keypoint ser considerado válido pelo MediaPipe.
  static const double minLandmarkConfidence = 0.50;

  /// Meta de taxa de quadros por segundo (FPS).
  static const int targetFPS = 30;

  /// Intervalo máximo entre quadros em milissegundos para manter 30+ FPS (~33ms por frame).
  static const int maxFrameBudgetMs = 33;

  // Cores para renderização do CustomPainter do esqueleto
  static const Color keypointColorLeft = Color(0xFF00E676); // Verde para lado esquerdo
  static const Color keypointColorRight = Color(0xFF2979FF); // Azul para lado direito
  static const Color skeletonColorExtended = Color(0xFFFF9100); // Laranja quando em extensão de soco
  static const Color skeletonColorNormal = Color(0xFF00E5FF); // Ciano normal
}
