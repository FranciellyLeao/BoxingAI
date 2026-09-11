import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../workout_plan/data/datasources/workout_plan_local_datasource.dart';
import '../../../workout_plan/presentation/controllers/plan_notifier.dart';
import '../../../workout_session/data/datasources/workout_local_datasource.dart';
import '../../../workout_session/data/repositories/workout_repository_impl.dart';
import '../../../workout_session/domain/repositories/workout_repository.dart';

import '../../data/datasources/camera_data_source.dart';
import '../../data/datasources/pose_detector_data_source.dart';
import '../../domain/entities/body_pose.dart';
import '../../domain/entities/punch_metrics.dart';
import '../../domain/usecases/detect_jab_usecase.dart';

enum RoundStatus { ready, inProgress, paused, completed }

/// Estado imutável do treino de boxe e controle de Round.
class PunchDetectorState {
  final bool isInitialized;
  final bool isLoading;
  final String? errorMessage;
  final BodyPose? currentPose;
  final PunchMetrics metrics;
  final double currentFPS;
  final RoundStatus roundStatus;
  final int remainingSeconds;
  final int roundNumber;
  final bool hasRecentHit;
  final WorkoutSessionResult? lastSessionResult;

  const PunchDetectorState({
    required this.isInitialized,
    required this.isLoading,
    this.errorMessage,
    this.currentPose,
    required this.metrics,
    required this.currentFPS,
    required this.roundStatus,
    required this.remainingSeconds,
    required this.roundNumber,
    required this.hasRecentHit,
    this.lastSessionResult,
  });

  factory PunchDetectorState.initial() => PunchDetectorState(
        isInitialized: false,
        isLoading: true,
        errorMessage: null,
        currentPose: null,
        metrics: PunchMetrics.initial(),
        currentFPS: 0.0,
        roundStatus: RoundStatus.ready,
        remainingSeconds: 180,
        roundNumber: 1,
        hasRecentHit: false,
        lastSessionResult: null,
      );

  PunchDetectorState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? errorMessage,
    BodyPose? currentPose,
    PunchMetrics? metrics,
    double? currentFPS,
    RoundStatus? roundStatus,
    int? remainingSeconds,
    int? roundNumber,
    bool? hasRecentHit,
    WorkoutSessionResult? lastSessionResult,
  }) {
    return PunchDetectorState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentPose: currentPose ?? this.currentPose,
      metrics: metrics ?? this.metrics,
      currentFPS: currentFPS ?? this.currentFPS,
      roundStatus: roundStatus ?? this.roundStatus,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      roundNumber: roundNumber ?? this.roundNumber,
      hasRecentHit: hasRecentHit ?? this.hasRecentHit,
      lastSessionResult: lastSessionResult ?? this.lastSessionResult,
    );
  }
}

/// Controller reativo do motor de Visão Computacional, treino e avanço do Plano de 30 Dias.
class PunchDetectorNotifier extends ValueNotifier<PunchDetectorState> {
  final CameraDataSource _cameraDataSource;
  final PoseDetectorDataSource _poseDetectorDataSource;
  final DetectJabUseCase _detectJabUseCase;
  final WorkoutRepository _workoutRepository;
  final WorkoutPlanLocalDataSource _planLocalDataSource;

  Timer? _roundTimer;
  Timer? _hitFeedbackTimer;
  final List<int> _frameTimestamps = [];

  PunchDetectorNotifier({
    CameraDataSource? cameraDataSource,
    PoseDetectorDataSource? poseDetectorDataSource,
    DetectJabUseCase? detectJabUseCase,
    WorkoutRepository? workoutRepository,
    WorkoutPlanLocalDataSource? planLocalDataSource,
  })  : _cameraDataSource = cameraDataSource ?? CameraDataSource(),
        _poseDetectorDataSource = poseDetectorDataSource ?? PoseDetectorDataSource(),
        _detectJabUseCase = detectJabUseCase ?? DetectJabUseCase(),
        _workoutRepository = workoutRepository ?? WorkoutRepositoryImpl(),
        _planLocalDataSource = planLocalDataSource ?? WorkoutPlanLocalDataSource(),
        super(PunchDetectorState.initial());

  CameraController? get cameraController => _cameraDataSource.controller;

  Future<void> initialize(DeviceOrientation deviceOrientation) async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);

      await _cameraDataSource.initializeCamera();

      value = value.copyWith(
        isInitialized: true,
        isLoading: false,
      );

      _cameraDataSource.startImageStream(
        deviceOrientation: deviceOrientation,
        onFrame: (inputImage) async {
          _updateFPS();

          final BodyPose? pose = await _poseDetectorDataSource.processImage(inputImage);

          if (pose != null) {
            final updatedMetrics = _detectJabUseCase.execute(pose, value.metrics);

            if (updatedMetrics.isPunchPeakDetected) {
              _triggerHitFeedback();
            }

            value = value.copyWith(
              currentPose: pose,
              metrics: updatedMetrics,
            );
          } else {
            value = value.copyWith(currentPose: null);
          }
        },
      );

      startRound();
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao inicializar a Câmera/IA: $e',
      );
    }
  }

  void startRound() {
    if (value.roundStatus == RoundStatus.inProgress) return;

    _roundTimer?.cancel();
    value = value.copyWith(roundStatus: RoundStatus.inProgress);

    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (value.remainingSeconds > 0) {
        value = value.copyWith(remainingSeconds: value.remainingSeconds - 1);
      } else {
        _roundTimer?.cancel();
        finishWorkoutAndSaveSession();
      }
    });
  }

  void pauseRound() {
    _roundTimer?.cancel();
    value = value.copyWith(roundStatus: RoundStatus.paused);
  }

  void resetRound() {
    _roundTimer?.cancel();
    _detectJabUseCase.reset();
    value = value.copyWith(
      roundStatus: RoundStatus.ready,
      remainingSeconds: 180,
      metrics: PunchMetrics.initial(),
      lastSessionResult: null,
    );
    startRound();
  }

  /// Conclui o treino, grava a sessão e avança automaticamente o plano de 30 dias.
  Future<WorkoutSessionResult> finishWorkoutAndSaveSession() async {
    _roundTimer?.cancel();
    _cameraDataSource.stopImageStream();

    final int durationExecuted = 180 - value.remainingSeconds;
    final int punchesCount = value.metrics.totalPunchesCount;

    final double avgExtension = (value.metrics.leftArmExtensionRatio + value.metrics.rightArmExtensionRatio) / 2;
    final double precision = (avgExtension * 100).clamp(75.0, 99.0);

    // 1. Salva a sessão no histórico e calcula XP/Streak
    final result = await _workoutRepository.saveCompletedSession(
      jabsCount: punchesCount,
      durationSeconds: durationExecuted == 0 ? 180 : durationExecuted,
      precisionPercentage: precision,
    );

    // 2. Avança automaticamente o dia no Plano de 30 Dias
    try {
      final days = await _planLocalDataSource.getPlanDays();
      final activeDay = days.firstWhere((d) => d.isUnlocked && !d.isCompleted, orElse: () => days.first);
      await _planLocalDataSource.completeDay(activeDay.dayNumber);
    } catch (_) {}

    value = value.copyWith(
      roundStatus: RoundStatus.completed,
      lastSessionResult: result,
    );

    return result;
  }

  void _triggerHitFeedback() {
    _hitFeedbackTimer?.cancel();
    value = value.copyWith(hasRecentHit: true);

    _hitFeedbackTimer = Timer(const Duration(milliseconds: 400), () {
      value = value.copyWith(hasRecentHit: false);
    });
  }

  void _updateFPS() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    _frameTimestamps.add(now);

    _frameTimestamps.removeWhere((timestamp) => now - timestamp > 1000);

    final double calculatedFPS = _frameTimestamps.length.toDouble();
    if ((calculatedFPS - value.currentFPS).abs() >= 1.0) {
      value = value.copyWith(currentFPS: calculatedFPS);
    }
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _hitFeedbackTimer?.cancel();
    _cameraDataSource.dispose();
    _poseDetectorDataSource.dispose();
    super.dispose();
  }
}
