import 'package:flutter/foundation.dart';

import '../../data/datasources/workout_plan_local_datasource.dart';
import '../../domain/entities/workout_day.dart';

/// Estado do Plano de 30 Dias.
class PlanState {
  final List<WorkoutDay> days;
  final WorkoutDay? currentActiveDay;
  final bool isLoading;

  const PlanState({
    required this.days,
    this.currentActiveDay,
    required this.isLoading,
  });

  factory PlanState.initial() => const PlanState(
        days: [],
        currentActiveDay: null,
        isLoading: true,
      );

  PlanState copyWith({
    List<WorkoutDay>? days,
    WorkoutDay? currentActiveDay,
    bool? isLoading,
  }) {
    return PlanState(
      days: days ?? this.days,
      currentActiveDay: currentActiveDay ?? this.currentActiveDay,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Controller reativo responsável por gerenciar os 30 dias de treino e desbloqueio progressivo.
class PlanNotifier extends ValueNotifier<PlanState> {
  final WorkoutPlanLocalDataSource _dataSource;

  PlanNotifier({WorkoutPlanLocalDataSource? dataSource})
      : _dataSource = dataSource ?? WorkoutPlanLocalDataSource(),
        super(PlanState.initial()) {
    loadPlan();
  }

  /// Carrega o estado do plano e identifica o dia ativo atual.
  Future<void> loadPlan() async {
    value = value.copyWith(isLoading: true);
    final days = await _dataSource.getPlanDays();

    // Encontra o primeiro dia desbloqueado que ainda não foi concluído
    final activeDay = days.firstWhere(
      (d) => d.isUnlocked && !d.isCompleted,
      orElse: () => days.lastWhere((d) => d.isUnlocked, orElse: () => days.first),
    );

    value = value.copyWith(
      days: days,
      currentActiveDay: activeDay,
      isLoading: false,
    );
  }

  /// Marca o dia ativo atual como concluído e liberta o dia seguinte.
  Future<void> completeCurrentDay() async {
    if (value.currentActiveDay == null) return;
    final int currentNum = value.currentActiveDay!.dayNumber;

    final updatedDays = await _dataSource.completeDay(currentNum);

    final nextActiveDay = updatedDays.firstWhere(
      (d) => d.isUnlocked && !d.isCompleted,
      orElse: () => updatedDays.last,
    );

    value = value.copyWith(
      days: updatedDays,
      currentActiveDay: nextActiveDay,
    );
  }

  /// Seleciona manualmente um dia desbloqueado para visualização no card.
  void selectDay(WorkoutDay day) {
    if (!day.isUnlocked) return;
    value = value.copyWith(currentActiveDay: day);
  }
}
