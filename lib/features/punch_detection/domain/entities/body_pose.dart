import 'pose_landmark.dart';

/// Entidade de domínio que agrupa os keypoints corporais extraídos no frame atual.
class BodyPose {
  final Map<PoseLandmarkType, PoseLandmark> landmarks;
  final int imageWidth;
  final int imageHeight;

  const BodyPose({
    required this.landmarks,
    required this.imageWidth,
    required this.imageHeight,
  });

  PoseLandmark? get leftShoulder => landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? get rightShoulder => landmarks[PoseLandmarkType.rightShoulder];

  PoseLandmark? get leftElbow => landmarks[PoseLandmarkType.leftElbow];
  PoseLandmark? get rightElbow => landmarks[PoseLandmarkType.rightElbow];

  PoseLandmark? get leftWrist => landmarks[PoseLandmarkType.leftWrist];
  PoseLandmark? get rightWrist => landmarks[PoseLandmarkType.rightWrist];

  /// Verifica se os keypoints essenciais para análise do braço esquerdo estão disponíveis com boa confiança.
  bool hasValidLeftArm(double minLikelihood) {
    return leftShoulder != null &&
        leftElbow != null &&
        leftWrist != null &&
        leftShoulder!.isConfident(minLikelihood) &&
        leftElbow!.isConfident(minLikelihood) &&
        leftWrist!.isConfident(minLikelihood);
  }

  /// Verifica se os keypoints essenciais para análise do braço direito estão disponíveis com boa confiança.
  bool hasValidRightArm(double minLikelihood) {
    return rightShoulder != null &&
        rightElbow != null &&
        rightWrist != null &&
        rightShoulder!.isConfident(minLikelihood) &&
        rightElbow!.isConfident(minLikelihood) &&
        rightWrist!.isConfident(minLikelihood);
  }
}
