/// Tipos de movimentos de defesa e esquiva.
enum DefenseType {
  none,
  slipLeft,
  slipRight,
  duck,
}

extension DefenseTypeExtension on DefenseType {
  String get displayName {
    switch (this) {
      case DefenseType.slipLeft:
        return 'ESQUIVA ESQUERDA (SLIP)';
      case DefenseType.slipRight:
        return 'ESQUIVA DIREITA (SLIP)';
      case DefenseType.duck:
        return 'DEFESA ABAIXADA (DUCK)';
      case DefenseType.none:
        return 'Sem Esquiva';
    }
  }
}

/// Métricas e contadores de movimentos defensivos (Slips e Ducks).
class DefenseMetrics {
  final DefenseType activeDefenseType;
  final bool isDefenseDetectedThisFrame;
  final int totalSlipsCount;
  final int totalDucksCount;

  const DefenseMetrics({
    required this.activeDefenseType,
    required this.isDefenseDetectedThisFrame,
    required this.totalSlipsCount,
    required this.totalDucksCount,
  });

  factory DefenseMetrics.initial() => const DefenseMetrics(
        activeDefenseType: DefenseType.none,
        isDefenseDetectedThisFrame: false,
        totalSlipsCount: 0,
        totalDucksCount: 0,
      );

  DefenseMetrics copyWith({
    DefenseType? activeDefenseType,
    bool? isDefenseDetectedThisFrame,
    int? totalSlipsCount,
    int? totalDucksCount,
  }) {
    return DefenseMetrics(
      activeDefenseType: activeDefenseType ?? this.activeDefenseType,
      isDefenseDetectedThisFrame: isDefenseDetectedThisFrame ?? this.isDefenseDetectedThisFrame,
      totalSlipsCount: totalSlipsCount ?? this.totalSlipsCount,
      totalDucksCount: totalDucksCount ?? this.totalDucksCount,
    );
  }
}
