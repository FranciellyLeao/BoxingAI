/// Enumeração dos tipos de pontos corporais (Landmarks) relevantes para análise do soco.
enum PoseLandmarkType {
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftHip,
  rightHip,
  unknown,
}

/// Entidade que representa um ponto corporal 3D detectado pelo MediaPipe Pose.
class PoseLandmark {
  final PoseLandmarkType type;
  final double x;
  final double y;
  final double z;
  final double likelihood;

  const PoseLandmark({
    required this.type,
    required this.x,
    required this.y,
    required this.z,
    required this.likelihood,
  });

  /// Retorna verdadeiro se a confiança de detecção for maior que o limiar especificado.
  bool isConfident(double minLikelihood) => likelihood >= minLikelihood;

  @override
  String toString() => 'PoseLandmark($type: x=${x.toStringAsFixed(1)}, y=${y.toStringAsFixed(1)}, likelihood=${(likelihood * 100).toStringAsFixed(1)}%)';
}
