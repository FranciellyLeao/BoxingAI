import '../../../../core/constants/vision_constants.dart';
import '../../../../core/utils/pose_math_utils.dart';
import '../entities/body_pose.dart';
import '../entities/punch_metrics.dart';
import '../entities/punch_type.dart';

enum _ArmState { guard, extending, extended, hookActive, retracting }

/// Usecase de negócio expandido para classificação e contagem dos 3 golpes (Jab, Cross, Hook).
class DetectJabUseCase {
  _ArmState _leftArmState = _ArmState.guard;
  _ArmState _rightArmState = _ArmState.guard;

  int _jabsCounter = 0;
  int _crossesCounter = 0;
  int _hooksCounter = 0;

  void reset() {
    _leftArmState = _ArmState.guard;
    _rightArmState = _ArmState.guard;
    _jabsCounter = 0;
    _crossesCounter = 0;
    _hooksCounter = 0;
  }

  /// Processa a pose corporal e classifica em tempo real se o movimento é Jab, Cross ou Hook.
  PunchMetrics execute(BodyPose pose, PunchMetrics currentMetrics) {
    double leftElbowAngle = 0.0;
    double leftExtensionRatio = 0.0;
    double rightElbowAngle = 0.0;
    double rightExtensionRatio = 0.0;

    bool isPunchDetectedThisFrame = false;
    PunchType activePunch = PunchType.none;

    // 1. Processa Braço Esquerdo (Geralmente Braço da Frente em Base Ortodoxa)
    if (pose.hasValidLeftArm(VisionConstants.minLandmarkConfidence)) {
      final shoulder = pose.leftShoulder!;
      final elbow = pose.leftElbow!;
      final wrist = pose.leftWrist!;

      leftElbowAngle = PoseMathUtils.calculateAngleDegrees(shoulder, elbow, wrist);
      leftExtensionRatio = PoseMathUtils.calculateArmExtensionRatio(shoulder, elbow, wrist);

      final bool isExtended = leftElbowAngle >= VisionConstants.jabMinElbowAngleDegrees &&
          leftExtensionRatio >= VisionConstants.jabMinExtensionRatio;

      final bool isHookPosition = PoseMathUtils.isElbowBentForHook(leftElbowAngle) &&
          pose.rightShoulder != null &&
          PoseMathUtils.isWristCrossingTorso(wrist, pose.rightShoulder!, true);

      if (isExtended && (_leftArmState == _ArmState.guard || _leftArmState == _ArmState.extending)) {
        // JAB DETECTADO (Braço da frente estendido)
        _leftArmState = _ArmState.extended;
        _jabsCounter++;
        isPunchDetectedThisFrame = true;
        activePunch = PunchType.jab;
      } else if (isHookPosition && _leftArmState == _ArmState.guard) {
        // HOOK DETECTADO (Braço esquerdo cruzado com ângulo de ~90°)
        _leftArmState = _ArmState.hookActive;
        _hooksCounter++;
        isPunchDetectedThisFrame = true;
        activePunch = PunchType.hook;
      } else if (leftElbowAngle <= VisionConstants.guardResetAngleDegrees) {
        _leftArmState = _ArmState.guard;
      }
    }

    // 2. Processa Braço Direito (Geralmente Braço de Trás em Base Ortodoxa)
    if (pose.hasValidRightArm(VisionConstants.minLandmarkConfidence)) {
      final shoulder = pose.rightShoulder!;
      final elbow = pose.rightElbow!;
      final wrist = pose.rightWrist!;

      rightElbowAngle = PoseMathUtils.calculateAngleDegrees(shoulder, elbow, wrist);
      rightExtensionRatio = PoseMathUtils.calculateArmExtensionRatio(shoulder, elbow, wrist);

      final bool isExtended = rightElbowAngle >= VisionConstants.jabMinElbowAngleDegrees &&
          rightExtensionRatio >= VisionConstants.jabMinExtensionRatio;

      final bool isHookPosition = PoseMathUtils.isElbowBentForHook(rightElbowAngle) &&
          pose.leftShoulder != null &&
          PoseMathUtils.isWristCrossingTorso(wrist, pose.leftShoulder!, false);

      if (isExtended && (_rightArmState == _ArmState.guard || _rightArmState == _ArmState.extending)) {
        // CROSS / DIRETO DETECTADO (Braço traseiro estendido com rotação)
        _rightArmState = _ArmState.extended;
        _crossesCounter++;
        isPunchDetectedThisFrame = true;
        activePunch = PunchType.cross;
      } else if (isHookPosition && _rightArmState == _ArmState.guard) {
        // HOOK DETECTADO (Braço direito em gancho lateral)
        _rightArmState = _ArmState.hookActive;
        _hooksCounter++;
        isPunchDetectedThisFrame = true;
        activePunch = PunchType.hook;
      } else if (rightElbowAngle <= VisionConstants.guardResetAngleDegrees) {
        _rightArmState = _ArmState.guard;
      }
    }

    return currentMetrics.copyWith(
      leftElbowAngle: leftElbowAngle,
      rightElbowAngle: rightElbowAngle,
      leftArmExtensionRatio: leftExtensionRatio,
      rightArmExtensionRatio: rightExtensionRatio,
      activePunchType: activePunch,
      isPunchPeakDetected: isPunchDetectedThisFrame,
      totalJabsCount: _jabsCounter,
      totalCrossesCount: _crossesCounter,
      totalHooksCount: _hooksCounter,
    );
  }
}
