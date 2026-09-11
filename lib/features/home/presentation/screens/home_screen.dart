import 'package:flutter/material.dart';

import '../../../../core/theme/cyber_boxing_theme.dart';
import '../../../profile/domain/entities/athlete_profile.dart';
import '../../../punch_detection/presentation/widgets/boxing_camera_view.dart';
import '../../../workout_plan/presentation/controllers/plan_notifier.dart';
import '../../../workout_plan/presentation/widgets/training_roadmap_card.dart';
import '../../../workout_session/data/repositories/workout_repository_impl.dart';
import '../../../workout_session/domain/repositories/workout_repository.dart';

/// Tela Principal (Home) integrada com o Plano de 30 Dias e estatísticas do atleta.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WorkoutRepository _workoutRepository;
  late final PlanNotifier _planNotifier;

  AthleteProfile _athleteProfile = AthleteProfile.initial();
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _workoutRepository = WorkoutRepositoryImpl();
    _planNotifier = PlanNotifier();

    _loadAthleteProfile();
  }

  Future<void> _loadAthleteProfile() async {
    final profile = await _workoutRepository.getAthleteProfile();
    if (mounted) {
      setState(() {
        _athleteProfile = profile;
        _isLoadingProfile = false;
      });
    }
  }

  void _startWorkout(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BoxingCameraView(),
      ),
    );
    // Ao retornar do treino, atualiza perfil e plano
    _loadAthleteProfile();
    _planNotifier.loadPlan();
  }

  @override
  void dispose() {
    _planNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberBoxingTheme.background,
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator(color: CyberBoxingTheme.neonGreen))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. CABEÇALHO DO PERFIL & STREAK REATIVO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: CyberBoxingTheme.neonGreen, width: 2.0),
                                boxShadow: CyberBoxingTheme.neonGlow,
                              ),
                              child: const CircleAvatar(
                                radius: 24,
                                backgroundColor: CyberBoxingTheme.surfaceCard,
                                child: Icon(Icons.person, color: Colors.white, size: 28),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _athleteProfile.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.black,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Text(
                                  _athleteProfile.rankTitle,
                                  style: const TextStyle(
                                    color: CyberBoxingTheme.neonGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Badge de Streak Atualizado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: CyberBoxingTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '${_athleteProfile.streakDays} DIAS',
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.black,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 2. CARDS DE ESTATÍSTICAS RÁPIDAS
                    const Text(
                      'RESUMO DE DESEMPENHO',
                      style: TextStyle(
                        color: CyberBoxingTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.sports_mma,
                            title: 'GOLPES TOTAIS',
                            value: '${_athleteProfile.totalJabs}',
                            accentColor: CyberBoxingTheme.neonGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star,
                            title: 'XP TOTAL',
                            value: '${_athleteProfile.totalXP}',
                            accentColor: Colors.amberAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.fitness_center,
                            title: 'TREINOS',
                            value: '${_athleteProfile.totalWorkouts}',
                            accentColor: CyberBoxingTheme.neonPink,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 3. WIDGET DO PLANO DE 30 DIAS & TRILHA DE PROGRESSO
                    TrainingRoadmapCard(
                      planNotifier: _planNotifier,
                      onStartWorkout: () => _startWorkout(context),
                    ),

                    const SizedBox(height: 20),

                    // 4. DICA DE CONFIGURAÇÃO DE CÂMERA
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: CyberBoxingTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: CyberBoxingTheme.surfaceCardBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.camera_front, color: CyberBoxingTheme.neonGreen, size: 24),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'O motor de Visão Computacional analisa a extensão dos seus braços on-device a 30+ FPS.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: CyberBoxingTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: CyberBoxingTheme.surfaceCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: CyberBoxingTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.black,
            ),
          ),
        ],
      ),
    );
  }
}
