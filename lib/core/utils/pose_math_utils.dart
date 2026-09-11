import 'dart:math' as math;
import '../../features/punch_detection/domain/entities/pose_landmark.dart';

/// Utilitário matemático otimizado para geometria 2D/3D e cálculo biomecânico de golpes (Jab, Cross, Hook).
class PoseMathUtils {
  /// Calcula o ângulo em graus no ponto central [p2] formado pelos segmentos (p1-p2) e (p3-p2).
  /// Exemplo: p1 = Ombro, p2 = Cotovelo (vértice), p3 = Punho.
  static double calculateAngleDegrees(
    PoseLandmark p1,
    PoseLandmark p2,
    PoseLandmark p3,
  ) {
    final double v1x = p1.x - p2.x;
    final double v1y = p1.y - p2.y;
    final double v1z = p1.z - p2.z;

    final double v2x = p3.x - p2.x;
    final double v2y = p3.y - p2.y;
    final double v2z = p3.z - p2.z;

    final double dotProduct = (v1x * v2x) + (v1y * v2y) + (v1z * v2z);
    final double mag1 = math.sqrt((v1x * v1x) + (v1y * v1y) + (v1z * v1z));
    final double mag2 = math.sqrt((v2x * v2x) + (v2y * v2y) + (v2z * v2z));

    if (mag1 == 0 || mag2 == 0) return 0.0;

    final double cosTheta = (dotProduct / (mag1 * mag2)).clamp(-1.0, 1.0);
    final double angleRadians = math.acos(cosTheta);

    return angleRadians * (180.0 / math.pi);
  }

  /// Calcula a distância euclidiana 3D entre dois pontos de landmark.
  static double calculateDistance3D(PoseLandmark p1, PoseLandmark p2) {
    final double dx = p1.x - p2.x;
    final double dy = p1.y - p2.y;
    final double dz = p1.z - p2.z;
    return math.sqrt((dx * dx) + (dy * dy) + (dz * dz));
  }

  /// Calcula a razão de extensão do braço (0.0 a 1.0).
  static double calculateArmExtensionRatio(
    PoseLandmark shoulder,
    PoseLandmark elbow,
    PoseLandmark wrist,
  ) {
    final double upperArmLength = calculateDistance3D(shoulder, elbow);
    final double forearmLength = calculateDistance3D(elbow, wrist);
    final double totalArmSegmentLength = upperArmLength + forearmLength;

    if (totalArmSegmentLength == 0) return 0.0;

    final double directDistance = calculateDistance3D(shoulder, wrist);
    return directDistance / totalArmSegmentLength;
  }

  /// Verifica se o ângulo do cotovelo está na faixa característica do HOOK (~90°, entre 75° e 115°).
  static bool isElbowBentForHook(double elbowAngleDegrees) {
    return elbowAngleDegrees >= 75.0 && elbowAngleDegrees <= 115.0;
  }

  /// Calcula o nível de rotação do ombro traseiro em relação à linha frontal (útil para detectar CROSS).
  static double calculateShoulderRotationDepth(PoseLandmark rearShoulder, PoseLandmark leadShoulder) {
    // No MediaPipe Pose, a coordenada Z representa a profundidade em relação à câmera
    return (leadShoulder.z - rearShoulder.z).abs();
  }

  /// Verifica se o punho cruzou a linha lateral do tronco (característica do HOOK).
  static bool isWristCrossingTorso(PoseLandmark wrist, PoseLandmark oppositeShoulder, bool isLeftArm) {
    if (isLeftArm) {
      return wrist.x >= oppositeShoulder.x - 20;
    } else {
      return wrist.x <= oppositeShoulder.x + 20;
    }
  }
}
