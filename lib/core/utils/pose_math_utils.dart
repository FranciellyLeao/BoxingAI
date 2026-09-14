import 'dart:math' as math;
import '../../features/punch_detection/domain/entities/pose_landmark.dart';

/// Utilitário matemático otimizado para geometria 2D/3D, projeção perspectiva e cálculos de Esquiva (Slip & Duck).
class PoseMathUtils {
  /// Calcula o ângulo em graus no ponto central [p2] formado pelos segmentos (p1-p2) e (p3-p2).
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

  /// Calcula a distância euclidiana 3D entre dois pontos.
  static double calculateDistance3D(PoseLandmark p1, PoseLandmark p2) {
    final double dx = p1.x - p2.x;
    final double dy = p1.y - p2.y;
    final double dz = p1.z - p2.z;
    return math.sqrt((dx * dx) + (dy * dy) + (dz * dz));
  }

  /// Razão de extensão do braço (0.0 a 1.0).
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

  /// Verifica se o ângulo do cotovelo é característico do HOOK (~90°).
  static bool isElbowBentForHook(double elbowAngleDegrees) {
    return elbowAngleDegrees >= 75.0 && elbowAngleDegrees <= 115.0;
  }

  /// Calcula o desvio lateral da cabeça em relação ao centro dos ombro/quadril para detectar SLIP LEFT / RIGHT.
  static double calculateHeadLateralShift({
    required PoseLandmark shoulderLeft,
    required PoseLandmark shoulderRight,
    required PoseLandmark wristOrNose,
  }) {
    final double shoulderMidX = (shoulderLeft.x + shoulderRight.x) / 2.0;
    return wristOrNose.x - shoulderMidX;
  }

  /// Calcula a queda vertical da cabeça em relação à linha dos ombros para detectar DUCK (agachamento).
  static double calculateHeadVerticalDrop({
    required PoseLandmark shoulderLeft,
    required PoseLandmark shoulderRight,
    required PoseLandmark headNode,
  }) {
    final double shoulderMidY = (shoulderLeft.y + shoulderRight.y) / 2.0;
    return headNode.y - shoulderMidY;
  }

  /// Transforma uma coordenada 3D com profundidade Z em um raio de projeção perspectiva para o Avatar 3D.
  static double calculatePerspectiveRadius(double baseRadius, double zDepth) {
    // Membros mais próximos da câmera (Z menor) recebem maior raio visual
    final double factor = (1.0 - (zDepth / 1000.0)).clamp(0.6, 1.8);
    return baseRadius * factor;
  }
}
