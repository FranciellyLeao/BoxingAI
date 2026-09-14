import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/cyber_boxing_theme.dart';
import '../../../workout_session/presentation/screens/round_summary_screen.dart';
import '../../domain/entities/punch_type.dart';
import '../controllers/punch_detector_notifier.dart';
import 'cyber_avatar_3d_painter.dart';
import 'punch_dashboard_overlay.dart';

/// Tela de Treino de Câmera com Stack de pré-visualização, Avatar 3D Cyber-Boxing volumétrico e HUD reativo.
class BoxingCameraView extends StatefulWidget {
  const BoxingCameraView({super.key});

  @override
  State<BoxingCameraView> createState() => _BoxingCameraViewState();
}

class _BoxingCameraViewState extends State<BoxingCameraView> with WidgetsBindingObserver {
  late final PunchDetectorNotifier _notifier;
  bool _isNavigatingToSummary = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifier = PunchDetectorNotifier();

    _notifier.addListener(_onStateChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
    });
  }

  void _initCamera() {
    final orientation = MediaQuery.of(context).orientation == Orientation.portrait
        ? DeviceOrientation.portraitUp
        : DeviceOrientation.landscapeLeft;
    _notifier.initialize(orientation);
  }

  void _onStateChange() {
    final state = _notifier.value;
    if (state.roundStatus == RoundStatus.completed && state.lastSessionResult != null && !_isNavigatingToSummary) {
      _isNavigatingToSummary = true;
      _navigateToSummaryScreen(state.lastSessionResult!);
    }
  }

  void _navigateToSummaryScreen(dynamic result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RoundSummaryScreen(
          session: result.session,
          updatedProfile: result.updatedProfile,
          onRepeatRound: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const BoxingCameraView()),
            );
          },
          onBackToHome: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _notifier.cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      _notifier.pauseRound();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifier.removeListener(_onStateChange);
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberBoxingTheme.background,
      body: ValueListenableBuilder<PunchDetectorState>(
        valueListenable: _notifier,
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: CyberBoxingTheme.neonGreen),
                  SizedBox(height: 20),
                  Text(
                    'Inicializando Câmera & IA de Avatar 3D...',
                    style: TextStyle(
                      color: CyberBoxingTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: CyberBoxingTheme.neonPink, size: 54),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _initCamera,
                      icon: const Icon(Icons.refresh),
                      label: const Text('TENTAR NOVAMENTE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberBoxingTheme.neonGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          final controller = _notifier.cameraController;
          if (controller == null || !controller.value.isInitialized) {
            return const SizedBox.shrink();
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Pré-visualização da Câmera em Tempo Real
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),

              // 2. CustomPaint com o RENDERIZADOR DO AVATAR/ROBÔ 3D CYBER-BOXING
              CustomPaint(
                painter: CyberAvatar3DPainter(
                  pose: state.currentPose,
                  isFrontCamera: true,
                  isArmExtended: state.metrics.activePunchType != PunchType.none || state.hasRecentHit,
                  activeDefenseType: state.metrics.defenseMetrics.activeDefenseType,
                ),
              ),

              // 3. HUD Flutuante Cyber-Boxing (Contador de Socos, Slips/Ducks, Round Timer, FPS)
              PunchDashboardOverlay(
                metrics: state.metrics,
                fps: state.currentFPS,
                roundStatus: state.roundStatus,
                remainingSeconds: state.remainingSeconds,
                hasRecentHit: state.hasRecentHit,
                onPauseToggle: () {
                  if (state.roundStatus == RoundStatus.inProgress) {
                    _notifier.pauseRound();
                  } else {
                    _notifier.startRound();
                  }
                },
                onReset: () async {
                  await _notifier.finishWorkoutAndSaveSession();
                },
                onBackPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      ),
    );
  }
}
