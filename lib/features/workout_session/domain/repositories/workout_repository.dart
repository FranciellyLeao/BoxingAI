import '../../../profile/domain/entities/athlete_profile.dart';
import '../../data/datasources/workout_local_datasource.dart';
import '../entities/workout_session.dart';

/// Interface do Repositório de Treino (Clean Architecture).
abstract class WorkoutRepository {
  Future<AthleteProfile> getAthleteProfile();
  Future<WorkoutSessionResult> saveCompletedSession({
    required int jabsCount,
    required int durationSeconds,
    required double precisionPercentage,
  });
}
