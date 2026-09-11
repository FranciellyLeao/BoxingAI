import 'package:isar/isar.dart';

import '../../../../core/storage/isar_database_service.dart';
import '../../../storage/data/models/workout_progress_model.dart';
import '../../domain/entities/workout_day.dart';
import 'workout_plan_local_datasource.dart';

/// Datasource de alta velocidade 100% local com Isar DB para o Plano de 30 Dias.
class WorkoutPlanIsarDataSource {
  final WorkoutPlanLocalDataSource _fallbackDataSource;

  WorkoutPlanIsarDataSource({WorkoutPlanLocalDataSource? fallbackDataSource})
      : _fallbackDataSource = fallbackDataSource ?? WorkoutPlanLocalDataSource();

  Isar? get _isar => IsarDatabaseService.instance.isar;

  /// Retorna a lista dos 30 dias de treino direto do banco Isar DB.
  Future<List<WorkoutDay>> getPlanDays() async {
    final isar = _isar;
    if (isar == null || !isar.isOpen) {
      return await _fallbackDataSource.getPlanDays();
    }

    final models = await isar.workoutProgressModels.where().sortByDayNumber().findAll();

    if (models.isEmpty) {
      final defaultDays = await _fallbackDataSource.getPlanDays();
      await isar.writeTxn(() async {
        for (final day in defaultDays) {
          await isar.workoutProgressModels.put(WorkoutProgressModel.fromEntity(day));
        }
      });
      return defaultDays;
    }

    return models.map((m) => m.toEntity()).toList();
  }

  /// Conclui o dia atual e libera o próximo dia na memória interna do celular via Isar.
  Future<List<WorkoutDay>> completeDay(int dayNumber) async {
    final isar = _isar;
    if (isar == null || !isar.isOpen) {
      return await _fallbackDataSource.completeDay(dayNumber);
    }

    final dayModel = await isar.workoutProgressModels.filter().dayNumberEqualTo(dayNumber).findFirst();
    final nextDayModel = await isar.workoutProgressModels.filter().dayNumberEqualTo(dayNumber + 1).findFirst();

    await isar.writeTxn(() async {
      if (dayModel != null) {
        dayModel.isCompleted = true;
        await isar.workoutProgressModels.put(dayModel);
      }
      if (nextDayModel != null) {
        nextDayModel.isUnlocked = true;
        await isar.workoutProgressModels.put(nextDayModel);
      }
    });

    return await getPlanDays();
  }
}
