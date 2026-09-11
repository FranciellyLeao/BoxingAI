import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/input_image_converter.dart';

typedef OnFrameCallback = Future<void> Function(InputImage inputImage);

/// Datasource responsável pela inicialização e gerenciamento de stream da Câmera Frontal.
class CameraDataSource {
  CameraController? _controller;
  CameraDescription? _frontCamera;
  bool _isProcessingFrame = false;

  CameraController? get controller => _controller;
  CameraDescription? get frontCamera => _frontCamera;

  /// Inicializa a Câmera Frontal com perfil otimizado para IA (Medium Resolution).
  Future<CameraController> initializeCamera() async {
    final List<CameraDescription> cameras = await availableCameras();

    // Seleciona a câmera frontal preferencialmente
    _frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      _frontCamera!,
      ResolutionPreset.medium,
      enableAudio: false, // Desativa áudio para economizar ciclo de CPU
      imageFormatGroup: ImageFormatGroup.nv21, // Otimizado no Android
    );

    await _controller!.initialize();
    return _controller!;
  }

  /// Inicia a captura contínua de quadros com mecanismo de Throttling para 30+ FPS.
  Future<void> startImageStream({
    required DeviceOrientation deviceOrientation,
    required OnFrameCallback onFrame,
  }) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    await _controller!.startImageStream((CameraImage cameraImage) async {
      // FRAME GATE / THROTTLING:
      // Se a inferência do frame anterior ainda estiver rodando, descarta o frame atual imediatamente.
      // Isso evita o acúmulo de memória (buffer bloat) e garante execução em tempo real a 30+ FPS.
      if (_isProcessingFrame) return;

      _isProcessingFrame = true;

      try {
        final InputImage? inputImage = InputImageConverter.inputImageFromCameraImage(
          image: cameraImage,
          camera: _frontCamera!,
          deviceOrientation: deviceOrientation,
        );

        if (inputImage != null) {
          await onFrame(inputImage);
        }
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  /// Interrompe o fluxo e desaloca a câmera.
  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  /// Descarta a instância da Câmera.
  Future<void> dispose() async {
    await stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }
}
