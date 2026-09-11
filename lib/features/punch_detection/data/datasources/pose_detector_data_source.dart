import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart' as ml_kit;
import '../../domain/entities/body_pose.dart';
import '../../domain/entities/pose_landmark.dart';

/// Datasource responsável pela comunicação direta com a biblioteca MediaPipe / ML Kit Pose Detection.
class PoseDetectorDataSource {
  late final ml_kit.PoseDetector _poseDetector;

  PoseDetectorDataSource() {
    // Configura o detector para modo STREAM (otimizado para rastreamento contínuo a 30-60 FPS)
    final options = ml_kit.PoseDetectorOptions(
      mode: ml_kit.PoseDetectionMode.stream,
      model: ml_kit.PoseDetectionModel.base,
    );
    _poseDetector = ml_kit.PoseDetector(options: options);
  }

  /// Processa a [InputImage] de forma assíncrona on-device e mapeia para a entidade [BodyPose].
  Future<BodyPose?> processImage(ml_kit.InputImage inputImage) async {
    try {
      final List<ml_kit.Pose> poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) return null;

      final ml_kit.Pose firstPose = poses.first;
      final Map<PoseLandmarkType, PoseLandmark> landmarkMap = {};

      // Mapeia os landmarks do ML Kit para a nossa camada de domínio
      firstPose.landmarks.forEach((type, landmark) {
        final domainType = _mapLandmarkType(type);
        if (domainType != PoseLandmarkType.unknown) {
          landmarkMap[domainType] = PoseLandmark(
            type: domainType,
            x: landmark.x,
            y: landmark.y,
            z: landmark.z,
            likelihood: landmark.likelihood,
          );
        }
      });

      final Size size = inputImage.metadata?.size ?? const Size(0, 0);

      return BodyPose(
        landmarks: landmarkMap,
        imageWidth: size.width.toInt(),
        imageHeight: size.height.toInt(),
      );
    } catch (e) {
      // Captura erros de processamento para evitar crashes no fluxo de vídeo
      return null;
    }
  }

  /// Mapeia tipos nativos do ML Kit para o enum de domínio [PoseLandmarkType].
  PoseLandmarkType _mapLandmarkType(ml_kit.PoseLandmarkType type) {
    switch (type) {
      case ml_kit.PoseLandmarkType.leftShoulder:
        return PoseLandmarkType.leftShoulder;
      case ml_kit.PoseLandmarkType.rightShoulder:
        return PoseLandmarkType.rightShoulder;
      case ml_kit.PoseLandmarkType.leftElbow:
        return PoseLandmarkType.leftElbow;
      case ml_kit.PoseLandmarkType.rightElbow:
        return PoseLandmarkType.rightElbow;
      case ml_kit.PoseLandmarkType.leftWrist:
        return PoseLandmarkType.leftWrist;
      case ml_kit.PoseLandmarkType.rightWrist:
        return PoseLandmarkType.rightWrist;
      case ml_kit.PoseLandmarkType.leftHip:
        return PoseLandmarkType.leftHip;
      case ml_kit.PoseLandmarkType.rightHip:
        return PoseLandmarkType.rightHip;
      default:
        return PoseLandmarkType.unknown;
    }
  }

  /// Libera os recursos nativos de memória ao encerrar a tela.
  Future<void> dispose() async {
    await _poseDetector.close();
  }
}
