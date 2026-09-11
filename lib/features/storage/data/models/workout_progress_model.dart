import 'package:isar/isar.dart';

import '../../../workout_plan/domain/entities/workout_day.dart';

@collection
class WorkoutProgressModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late int dayNumber;

  late String phaseName;
  late String title;
  late String description;
  late int targetJabs;
  late int targetCrosses;
  late int targetHooks;
  late int durationSeconds;
  late bool isCompleted;
  late bool isUnlocked;
  late String difficulty;

  WorkoutProgressModel();

  factory WorkoutProgressModel.fromEntity(WorkoutDay entity) {
    return WorkoutProgressModel()
      ..dayNumber = entity.dayNumber
      ..phaseName = entity.phaseName
      ..title = entity.title
      ..description = entity.description
      ..targetJabs = entity.targetJabs
      ..targetCrosses = entity.targetCrosses
      ..targetHooks = entity.targetHooks
      ..durationSeconds = entity.durationSeconds
      ..isCompleted = entity.isCompleted
      ..isUnlocked = entity.isUnlocked
      ..difficulty = entity.difficulty;
  }

  WorkoutDay toEntity() {
    return WorkoutDay(
      dayNumber: dayNumber,
      phaseName: phaseName,
      title: title,
      description: description,
      targetJabs: targetJabs,
      targetCrosses: targetCrosses,
      targetHooks: targetHooks,
      durationSeconds: durationSeconds,
      isCompleted: isCompleted,
      isUnlocked: isUnlocked,
      difficulty: difficulty,
    );
  }
}
