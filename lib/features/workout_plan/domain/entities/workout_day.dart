/// Entidade que representa um dia de treino no Plano de 30 Dias.
class WorkoutDay {
  final int dayNumber;
  final String phaseName;
  final String title;
  final String description;
  final int targetJabs;
  final int targetCrosses;
  final int targetHooks;
  final int durationSeconds;
  final bool isCompleted;
  final bool isUnlocked;
  final String difficulty;

  const WorkoutDay({
    required this.dayNumber,
    required this.phaseName,
    required this.title,
    required this.description,
    required this.targetJabs,
    required this.targetCrosses,
    required this.targetHooks,
    required this.durationSeconds,
    required this.isCompleted,
    required this.isUnlocked,
    required this.difficulty,
  });

  WorkoutDay copyWith({
    int? dayNumber,
    String? phaseName,
    String? title,
    String? description,
    int? targetJabs,
    int? targetCrosses,
    int? targetHooks,
    int? durationSeconds,
    bool? isCompleted,
    bool? isUnlocked,
    String? difficulty,
  }) {
    return WorkoutDay(
      dayNumber: dayNumber ?? this.dayNumber,
      phaseName: phaseName ?? this.phaseName,
      title: title ?? this.title,
      description: description ?? this.description,
      targetJabs: targetJabs ?? this.targetJabs,
      targetCrosses: targetCrosses ?? this.targetCrosses,
      targetHooks: targetHooks ?? this.targetHooks,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'phaseName': phaseName,
        'title': title,
        'description': description,
        'targetJabs': targetJabs,
        'targetCrosses': targetCrosses,
        'targetHooks': targetHooks,
        'durationSeconds': durationSeconds,
        'isCompleted': isCompleted,
        'isUnlocked': isUnlocked,
        'difficulty': difficulty,
      };

  factory WorkoutDay.fromJson(Map<String, dynamic> json) => WorkoutDay(
        dayNumber: json['dayNumber'] as int,
        phaseName: json['phaseName'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        targetJabs: json['targetJabs'] as int,
        targetCrosses: json['targetCrosses'] as int,
        targetHooks: json['targetHooks'] as int,
        durationSeconds: json['durationSeconds'] as int,
        isCompleted: json['isCompleted'] as bool,
        isUnlocked: json['isUnlocked'] as bool,
        difficulty: json['difficulty'] as String,
      );
}
