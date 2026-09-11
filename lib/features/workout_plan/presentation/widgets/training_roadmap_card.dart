import 'package:flutter/material.dart';

import '../../../../core/theme/cyber_boxing_theme.dart';
import '../controllers/plan_notifier.dart';
import '../domain/entities/workout_day.dart';

/// Widget da HomeScreen: Card Interativo do Treino do Dia Atual e Trilha de Progresso de 30 Dias.
class TrainingRoadmapCard extends StatelessWidget {
  final PlanNotifier planNotifier;
  final VoidCallback onStartWorkout;

  const TrainingRoadmapCard({
    super.key,
    required this.planNotifier,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlanState>(
      valueListenable: planNotifier,
      builder: (context, state, child) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator(color: CyberBoxingTheme.neonGreen));
        }

        final activeDay = state.currentActiveDay;
        if (activeDay == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARD PRINCIPAL DO DIA ATUAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: CyberBoxingTheme.cyberCardGradient,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: CyberBoxingTheme.neonGreen.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: CyberBoxingTheme.neonGreen.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho: Número do Dia e Fase
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: CyberBoxingTheme.neonGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CyberBoxingTheme.neonGreen.withOpacity(0.4)),
                        ),
                        child: Text(
                          'DIA ${activeDay.dayNumber.toString().padLeft(2, '0')} DE 30',
                          style: const TextStyle(
                            color: CyberBoxingTheme.neonGreen,
                            fontWeight: FontWeight.black,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          activeDay.difficulty.toUpperCase(),
                          style: const TextStyle(
                            color: CyberBoxingTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Título da Sessão & Fase
                  Text(
                    activeDay.phaseName,
                    style: const TextStyle(
                      color: CyberBoxingTheme.neonCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeDay.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeDay.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Metas de Golpes para o Dia
                  Row(
                    children: [
                      _TargetBadge(
                        label: '${activeDay.targetJabs} JABS',
                        color: CyberBoxingTheme.neonGreen,
                      ),
                      if (activeDay.targetCrosses > 0) ...[
                        const SizedBox(width: 8),
                        _TargetBadge(
                          label: '${activeDay.targetCrosses} CROSSES',
                          color: Colors.orangeAccent,
                        ),
                      ],
                      if (activeDay.targetHooks > 0) ...[
                        const SizedBox(width: 8),
                        _TargetBadge(
                          label: '${activeDay.targetHooks} HOOKS',
                          color: CyberBoxingTheme.neonPink,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Botão de Ação Rápida "TREINAR DIA XX"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onStartWorkout,
                      icon: const Icon(Icons.sports_mma, color: Colors.black, size: 24),
                      label: Text(
                        'TREINAR DIA ${activeDay.dayNumber.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.black,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberBoxingTheme.neonGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        boxShadow: CyberBoxingTheme.neonGlow,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. TRILHA HORIZONTAL DE PROGRESSO DE 30 DIAS
            const Text(
              'TRILHA DO PLANO DE 30 DIAS',
              style: TextStyle(
                color: CyberBoxingTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.days.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final day = state.days[index];
                  final bool isSelected = activeDay.dayNumber == day.dayNumber;

                  return _RoadmapNode(
                    day: day,
                    isSelected: isSelected,
                    onTap: () => planNotifier.selectDay(day),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TargetBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TargetBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RoadmapNode extends StatelessWidget {
  final WorkoutDay day;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoadmapNode({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white12;
    Color bgColor = CyberBoxingTheme.surfaceCard;
    Widget iconWidget = Text(
      '${day.dayNumber}',
      style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold),
    );

    if (day.isCompleted) {
      borderColor = CyberBoxingTheme.neonGreen;
      bgColor = CyberBoxingTheme.neonGreen.withOpacity(0.2);
      iconWidget = const Icon(Icons.check, color: CyberBoxingTheme.neonGreen, size: 20);
    } else if (isSelected) {
      borderColor = CyberBoxingTheme.neonCyan;
      bgColor = CyberBoxingTheme.neonCyan.withOpacity(0.25);
      iconWidget = Text(
        '${day.dayNumber}',
        style: const TextStyle(color: CyberBoxingTheme.neonCyan, fontWeight: FontWeight.black, fontSize: 16),
      );
    } else if (!day.isUnlocked) {
      borderColor = Colors.white10;
      bgColor = Colors.black45;
      iconWidget = const Icon(Icons.lock_outline, color: Colors.white24, size: 18);
    }

    return GestureDetector(
      onTap: day.isUnlocked ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 58,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CyberBoxingTheme.neonCyan.withOpacity(0.4),
                    blurRadius: 10,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 2),
            Text(
              'DIA ${day.dayNumber}',
              style: TextStyle(
                color: day.isUnlocked ? Colors.white : Colors.white30,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
