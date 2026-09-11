import '../../../profile/domain/entities/athlete_profile.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_isar_datasource.dart';

/// Implementação concreta do repositório de treinos operando sobre o banco Isar DB 100% local.
class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutIsarDataSource _isarDataSource;

  WorkoutRepositoryImpl({WorkoutIsarDataSource? isarDataSource})
      : _isarDataSource = isarDataSource ?? WorkoutIsarDataSource();

  @override
  Future<AthleteProfile> getAthleteProfile() async {
    return await _isarDataSource.getProfile();
  }

  @override
  Future<dynamic> saveCompletedSession({
    required int jabsCount,
    required int durationSeconds,
    required double precisionPercentage,
  }) async {
    return await _isarDataSource.recordWorkoutSession(
      jabsCount: jabsCount,
      durationSeconds: durationSeconds,
      precisionPercentage: precisionPercentage,
    );
  }
}
