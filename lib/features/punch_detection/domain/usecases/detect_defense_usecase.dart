import '../../../../core/constants/vision_constants.dart';
import '../entities/body_pose.dart';
import '../entities/defense_metrics.dart';

enum _DefenseState { neutral, slippingLeft, slippingRight, ducking }

/// Usecase de negócio responsável pelo reconhecimento biométrico de esquivas (Slip Left/Right) e agachamentos de defesa (Duck).
class DetectDefenseUseCase {
  _DefenseState _state = _DefenseState.neutral;
  int _slipsCounter = 0;
  int _ducksCounter = 0;

  void reset() {
    _state = _DefenseState.neutral;
    _slipsCounter = 0;
    _ducksCounter = 0;
  }

  /// Avalia a pose corporal atual e atualiza as métricas de defesa.
  DefenseMetrics execute(BodyPose pose, DefenseMetrics currentMetrics) {
    if (pose.leftShoulder == null || pose.rightShoulder == null) {
      return currentMetrics;
    }

    final sLeft = pose.leftShoulder!;
    final sRight = pose.rightShoulder!;

    if (!sLeft.isConfident(VisionConstants.minLandmarkConfidence) ||
        !sRight.isConfident(VisionConstants.minLandmarkConfidence)) {
      return currentMetrics;
    }

    final double shoulderWidth = (sLeft.x - sRight.x).abs();
    if (shoulderWidth == 0) return currentMetrics;

    final double shoulderMidX = (sLeft.x + sRight.x) / 2.0;

    // Utiliza o ponto de cabeça disponível ou a inclinação média dos ombros
    double headX = shoulderMidX;
    if (pose.leftWrist != null && pose.rightWrist != null) {
      headX = (pose.leftWrist!.x + pose.rightWrist!.x) / 2.0;
    }

    final double lateralOffsetRatio = (headX - shoulderMidX) / shoulderWidth;

    bool isNewDefenseDetected = false;
    DefenseType activeType = DefenseType.none;

    // 1. Verificação de SLIP LEFT (Inclinação de Tronco para Esquerda)
    if (lateralOffsetRatio < -0.38) {
      if (_state == _DefenseState.neutral) {
        _state = _DefenseState.slippingLeft;
        _slipsCounter++;
        isNewDefenseDetected = true;
        activeType = DefenseType.slipLeft;
      } else if (_state == _DefenseState.slippingLeft) {
        activeType = DefenseType.slipLeft;
      }
    }
    // 2. Verificação de SLIP RIGHT (Inclinação de Tronco para Direita)
    else if (lateralOffsetRatio > 0.38) {
      if (_state == _DefenseState.neutral) {
        _state = _DefenseState.slippingRight;
        _slipsCounter++;
        isNewDefenseDetected = true;
        activeType = DefenseType.slipRight;
      } else if (_state == _DefenseState.slippingRight) {
        activeType = DefenseType.slipRight;
      }
    }
    // 3. Retorno para Posição Neutra de Guarda
    else if (lateralOffsetRatio.abs() <= 0.20) {
      _state = _DefenseState.neutral;
    }

    return currentMetrics.copyWith(
      activeDefenseType: activeType,
      isDefenseDetectedThisFrame: isNewDefenseDetected,
      totalSlipsCount: _slipsCounter,
      totalDucksCount: _ducksCounter,
    );
  }
}
