import 'package:isar/isar.dart';

import '../../../workout_session/domain/entities/workout_session.dart';

@collection
class WorkoutSessionModel {
  Id id = Isar.autoIncrement;

  late int timestamp;
  late int durationSeconds;
  late int jabsCount;
  late double precisionPercentage;
  late int xpEarned;

  WorkoutSessionModel();

  factory WorkoutSessionModel.fromEntity(WorkoutSession session) {
    return WorkoutSessionModel()
      ..timestamp = session.timestamp
      ..durationSeconds = session.durationSeconds
      ..jabsCount = session.jabsCount
      ..precisionPercentage = session.precisionPercentage
      ..xpEarned = session.xpEarned;
  }

  WorkoutSession toEntity() {
    return WorkoutSession(
      id: id.toString(),
      timestamp: timestamp,
      durationSeconds: durationSeconds,
      jabsCount: jabsCount,
      precisionPercentage: precisionPercentage,
      xpEarned: xpEarned,
    );
  }
}
