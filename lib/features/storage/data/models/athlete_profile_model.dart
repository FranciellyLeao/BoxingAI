import 'package:isar/isar.dart';

import '../../../profile/domain/entities/athlete_profile.dart';

@collection
class AthleteProfileModel {
  Id id = 1; // ID fixo para o perfil do usuário ativo

  late String name;
  late String rankTitle;
  late int totalJabs;
  late int totalWorkouts;
  late int totalXP;
  late int streakDays;
  int? lastWorkoutTimestamp;

  AthleteProfileModel();

  factory AthleteProfileModel.fromEntity(AthleteProfile profile) {
    return AthleteProfileModel()
      ..id = 1
      ..name = profile.name
      ..rankTitle = profile.rankTitle
      ..totalJabs = profile.totalJabs
      ..totalWorkouts = profile.totalWorkouts
      ..totalXP = profile.totalXP
      ..streakDays = profile.streakDays
      ..lastWorkoutTimestamp = profile.lastWorkoutTimestamp;
  }

  AthleteProfile toEntity() {
    return AthleteProfile(
      id: id.toString(),
      name: name,
      rankTitle: rankTitle,
      totalJabs: totalJabs,
      totalWorkouts: totalWorkouts,
      totalXP: totalXP,
      streakDays: streakDays,
      lastWorkoutTimestamp: lastWorkoutTimestamp,
    );
  }
}
