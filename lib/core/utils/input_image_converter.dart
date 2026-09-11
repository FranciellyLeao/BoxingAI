import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Converter de alta performance que transforma os frames brutos da Câmera [CameraImage]
/// em objetos [InputImage] exigidos pelo motor on-device do ML Kit Pose Detection.
class InputImageConverter {
  /// Converte um [CameraImage] recebido no callback do stream em [InputImage].
  static InputImage? inputImageFromCameraImage({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) {
    // 1. Determina a rotação da imagem com base no sensor da câmera e na orientação do aparelho
    final InputImageRotation? rotation = _calculateRotation(
      sensorOrientation: camera.sensorOrientation,
      deviceOrientation: deviceOrientation,
      isFrontCamera: camera.lensDirection == CameraLensDirection.front,
    );

    if (rotation == null) return null;

    // 2. Determina o formato da imagem (YUV_420_888 para Android, BGRA8888 para iOS)
    final InputImageFormat? format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (format == null) return null;

    // 3. Concatena os planos de memória se necessário (YUV420 tem 3 planos no Android)
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final Uint8List bytes = allBytes.done().buffer.asUint8List();

    // 4. Constrói os metadados da imagem para a inferência em C++
    final InputImageMetadata metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  /// Calcula o valor exato de rotação do frame para manter o alinhamento corporal correto.
  static InputImageRotation? _calculateRotation({
    required int sensorOrientation,
    required DeviceOrientation deviceOrientation,
    required bool isFrontCamera,
  }) {
    int rotationDegrees = 0;

    switch (deviceOrientation) {
      case DeviceOrientation.portraitUp:
        rotationDegrees = 0;
        break;
      case DeviceOrientation.landscapeLeft:
        rotationDegrees = 90;
        break;
      case DeviceOrientation.portraitDown:
        rotationDegrees = 180;
        break;
      case DeviceOrientation.landscapeRight:
        rotationDegrees = 270;
        break;
    }

    int resultDegrees;
    if (isFrontCamera) {
      resultDegrees = (sensorOrientation + rotationDegrees) % 360;
    } else {
      resultDegrees = (sensorOrientation - rotationDegrees + 360) % 360;
    }

    return InputImageRotationValue.fromRawValue(resultDegrees);
  }
}
