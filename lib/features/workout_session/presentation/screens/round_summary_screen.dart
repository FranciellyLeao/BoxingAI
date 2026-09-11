import 'package:flutter/material.dart';

import '../../../../core/theme/cyber_boxing_theme.dart';
import '../../../profile/domain/entities/athlete_profile.dart';
import '../entities/workout_session.dart';

/// Tela de Resumo de Fim de Round com detalhamento de golpes (Jabs, Crosses, Hooks).
class RoundSummaryScreen extends StatelessWidget {
  final WorkoutSession session;
  final AthleteProfile updatedProfile;
  final VoidCallback onRepeatRound;
  final VoidCallback onBackToHome;

  const RoundSummaryScreen({
    super.key,
    required this.session,
    required this.updatedProfile,
    required this.onRepeatRound,
    required this.onBackToHome,
  });

  String _formatDuration(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberBoxingTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 1. CABEÇALHO COM TROFÉU NEON E TÍTULO
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CyberBoxingTheme.neonGreen.withOpacity(0.12),
                  border: Border.all(color: CyberBoxingTheme.neonGreen, width: 2),
                  boxShadow: CyberBoxingTheme.neonGlow,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: CyberBoxingTheme.neonGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ROUND 1 CONCLUÍDO!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.black,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Análise Biomecânica de Golpes On-Device',
                style: TextStyle(
                  color: CyberBoxingTheme.textSecondary,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 24),

              // 2. GRID DE ESTATÍSTICAS DA SESSÃO
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryMetricCard(
                            icon: Icons.sports_mma,
                            title: 'TOTAL DE GOLPES',
                            value: '${session.jabsCount}',
                            accentColor: CyberBoxingTheme.neonGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryMetricCard(
                            icon: Icons.center_focus_strong,
                            title: 'PRECISÃO MÉDIA',
                            value: '${session.precisionPercentage.toStringAsFixed(0)}%',
                            accentColor: CyberBoxingTheme.neonCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryMetricCard(
                            icon: Icons.timer,
                            title: 'TEMPO DE TREINO',
                            value: _formatDuration(session.durationSeconds),
                            accentColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryMetricCard(
                            icon: Icons.star,
                            title: 'XP GANHO',
                            value: '+${session.xpEarned} XP',
                            accentColor: Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. CARD DE STREAK E XP ACUMULADO NO PERFIL
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: CyberBoxingTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: CyberBoxingTheme.neonGreen.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: CyberBoxingTheme.neonGreen.withOpacity(0.15),
                            blurRadius: 16,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🔥', style: TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STREAK DE OFENSIVA: ${updatedProfile.streakDays} DIAS',
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.black,
                                    fontSize: 13,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'XP Total Acumulado: ${updatedProfile.totalXP} XP',
                                  style: const TextStyle(
                                    color: CyberBoxingTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. BOTÕES DE AÇÃO INFERIORES
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: onRepeatRound,
                      icon: const Icon(Icons.refresh, color: CyberBoxingTheme.neonGreen),
                      label: const Text(
                        'REFAZER ROUND',
                        style: TextStyle(
                          color: CyberBoxingTheme.neonGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: CyberBoxingTheme.neonGreen, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onBackToHome,
                      icon: const Icon(Icons.home, color: Colors.black),
                      label: const Text(
                        'VOLTAR À HOME',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.black,
                          fontSize: 15,
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _SummaryMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: CyberBoxingTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: CyberBoxingTheme.surfaceCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: CyberBoxingTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 20,
              fontWeight: FontWeight.black,
            ),
          ),
        ],
      ),
    );
  }
}
