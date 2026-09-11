/// Entidade de domínio que representa o perfil do atleta e suas conquistas acumuladas.
class AthleteProfile {
  final String id;
  final String name;
  final String rankTitle;
  final int totalJabs;
  final int totalWorkouts;
  final int totalXP;
  final int streakDays;
  final int? lastWorkoutTimestamp;

  const AthleteProfile({
    required this.id,
    required this.name,
    required this.rankTitle,
    required this.totalJabs,
    required this.totalWorkouts,
    required this.totalXP,
    required this.streakDays,
    this.lastWorkoutTimestamp,
  });

  factory AthleteProfile.initial() => const AthleteProfile(
        id: 'user_01',
        name: 'ALEX "THE HULK"',
        rankTitle: 'PESO PESADO • NÍVEL 5',
        totalJabs: 1240,
        totalWorkouts: 14,
        totalXP: 3850,
        streakDays: 7,
        lastWorkoutTimestamp: null,
      );

  AthleteProfile copyWith({
    String? id,
    String? name,
    String? rankTitle,
    int? totalJabs,
    int? totalWorkouts,
    int? totalXP,
    int? streakDays,
    int? lastWorkoutTimestamp,
  }) {
    return AthleteProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      rankTitle: rankTitle ?? this.rankTitle,
      totalJabs: totalJabs ?? this.totalJabs,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalXP: totalXP ?? this.totalXP,
      streakDays: streakDays ?? this.streakDays,
      lastWorkoutTimestamp: lastWorkoutTimestamp ?? this.lastWorkoutTimestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rankTitle': rankTitle,
        'totalJabs': totalJabs,
        'totalWorkouts': totalWorkouts,
        'totalXP': totalXP,
        'streakDays': streakDays,
        'lastWorkoutTimestamp': lastWorkoutTimestamp,
      };

  factory AthleteProfile.fromJson(Map<String, dynamic> json) => AthleteProfile(
        id: json['id'] as String? ?? 'user_01',
        name: json['name'] as String? ?? 'ALEX "THE HULK"',
        rankTitle: json['rankTitle'] as String? ?? 'PESO PESADO • NÍVEL 5',
        totalJabs: json['totalJabs'] as int? ?? 1240,
        totalWorkouts: json['totalWorkouts'] as int? ?? 14,
        totalXP: json['totalXP'] as int? ?? 3850,
        streakDays: json['streakDays'] as int? ?? 7,
        lastWorkoutTimestamp: json['lastWorkoutTimestamp'] as int?,
      );
}
