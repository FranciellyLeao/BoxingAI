import 'package:isar/isar.dart';

import '../../../../core/storage/isar_database_service.dart';
import '../../../profile/domain/entities/athlete_profile.dart';
import '../../../storage/data/models/athlete_profile_model.dart';
import '../../../storage/data/models/workout_session_model.dart';
import '../../domain/entities/workout_session.dart';
import 'workout_local_datasource.dart';

/// Datasource local Isar DB de alta performance para perfil e histórico de sessões.
class WorkoutIsarDataSource {
  final WorkoutLocalDataSource _fallbackDataSource;

  WorkoutIsarDataSource({WorkoutLocalDataSource? fallbackDataSource})
      : _fallbackDataSource = fallbackDataSource ?? WorkoutLocalDataSource();

  Isar? get _isar => IsarDatabaseService.instance.isar;

  Future<AthleteProfile> getProfile() async {
    final isar = _isar;
    if (isar == null || !isar.isOpen) {
      return await _fallbackDataSource.getProfile();
    }

    final model = await isar.athleteProfileModels.get(1);

    if (model == null) {
      final initialProfile = AthleteProfile.initial();
      await isar.writeTxn(() async {
        await isar.athleteProfileModels.put(AthleteProfileModel.fromEntity(initialProfile));
      });
      return initialProfile;
    }

    return model.toEntity();
  }

  Future<WorkoutSessionResult> recordWorkoutSession({
    required int jabsCount,
    required int durationSeconds,
    required double precisionPercentage,
  }) async {
    final isar = _isar;
    if (isar == null || !isar.isOpen) {
      return await _fallbackDataSource.recordWorkoutSession(
        jabsCount: jabsCount,
        durationSeconds: durationSeconds,
        precisionPercentage: precisionPercentage,
      );
    }

    final currentProfile = await getProfile();
    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    final int baseJabXP = jabsCount * 10;
    final int precisionBonus = (precisionPercentage * 2).toInt();
    final int roundBonus = 100;
    final int xpEarned = baseJabXP + precisionBonus + roundBonus;

    final int newStreak = _calculateUpdatedStreak(
      currentStreak: currentProfile.streakDays,
      lastWorkoutTimestamp: currentProfile.lastWorkoutTimestamp,
      nowTimestamp: nowMs,
    );

    final updatedProfile = currentProfile.copyWith(
      totalJabs: currentProfile.totalJabs + jabsCount,
      totalWorkouts: currentProfile.totalWorkouts + 1,
      totalXP: currentProfile.totalXP + xpEarned,
      streakDays: newStreak,
      lastWorkoutTimestamp: nowMs,
    );

    final session = WorkoutSession(
      id: 'session_$nowMs',
      timestamp: nowMs,
      durationSeconds: durationSeconds,
      jabsCount: jabsCount,
      precisionPercentage: precisionPercentage,
      xpEarned: xpEarned,
    );

    await isar.writeTxn(() async {
      await isar.athleteProfileModels.put(AthleteProfileModel.fromEntity(updatedProfile));
      await isar.workoutSessionModels.put(WorkoutSessionModel.fromEntity(session));
    });

    return WorkoutSessionResult(
      session: session,
      updatedProfile: updatedProfile,
    );
  }

  int _calculateUpdatedStreak({
    required int currentStreak,
    required int? lastWorkoutTimestamp,
    required int nowTimestamp,
  }) {
    if (lastWorkoutTimestamp == null) return 1;

    final DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastWorkoutTimestamp);
    final DateTime nowDate = DateTime.fromMillisecondsSinceEpoch(nowTimestamp);

    final DateTime lastDayOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final DateTime nowDayOnly = DateTime(nowDate.year, nowDate.month, nowDate.day);

    final int differenceInDays = nowDayOnly.difference(lastDayOnly).inDays;

    if (differenceInDays == 0) {
      return currentStreak;
    } else if (differenceInDays == 1) {
      return currentStreak + 1;
    } else {
      return 1;
    }
  }
}
