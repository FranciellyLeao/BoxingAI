/// Entidade que representa uma sessão de treino/round concluída com IA.
class WorkoutSession {
  final String id;
  final int timestamp;
  final int durationSeconds;
  final int jabsCount;
  final double precisionPercentage;
  final int xpEarned;

  const WorkoutSession({
    required this.id,
    required this.timestamp,
    required this.durationSeconds,
    required this.jabsCount,
    required this.precisionPercentage,
    required this.xpEarned,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp,
        'durationSeconds': durationSeconds,
        'jabsCount': jabsCount,
        'precisionPercentage': precisionPercentage,
        'xpEarned': xpEarned,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String,
        timestamp: json['timestamp'] as int,
        durationSeconds: json['durationSeconds'] as int,
        jabsCount: json['jabsCount'] as int,
        precisionPercentage: (json['precisionPercentage'] as num).toDouble(),
        xpEarned: json['xpEarned'] as int,
      );
}
