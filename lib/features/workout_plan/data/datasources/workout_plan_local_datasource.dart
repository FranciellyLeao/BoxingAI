import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/workout_day.dart';

/// Datasource local do Plano de Treinos de 30 Dias com currículo de 3 fases e persistência em SharedPreferences.
class WorkoutPlanLocalDataSource {
  static const String _planStorageKey = 'cyber_boxing_plan_30_days_progress';

  /// Carrega os 30 dias do plano. Se não houver registro salvo, gera o currículo inicial.
  Future<List<WorkoutDay>> getPlanDays() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_planStorageKey);

    if (jsonString == null) {
      final initialPlan = _generateDefault30DayPlan();
      await savePlanDays(initialPlan);
      return initialPlan;
    }

    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => WorkoutDay.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      final initialPlan = _generateDefault30DayPlan();
      await savePlanDays(initialPlan);
      return initialPlan;
    }
  }

  /// Salva o estado dos 30 dias no dispositivo.
  Future<void> savePlanDays(List<WorkoutDay> planDays) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(planDays.map((day) => day.toJson()).toList());
    await prefs.setString(_planStorageKey, jsonString);
  }

  /// Conclui o dia atual e desbloqueia automaticamente o dia seguinte.
  Future<List<WorkoutDay>> completeDay(int dayNumber) async {
    final planDays = await getPlanDays();
    final updatedDays = planDays.map((day) {
      if (day.dayNumber == dayNumber) {
        return day.copyWith(isCompleted: true);
      } else if (day.dayNumber == dayNumber + 1) {
        return day.copyWith(isUnlocked: true);
      }
      return day;
    }).toList();

    await savePlanDays(updatedDays);
    return updatedDays;
  }

  /// Gerador estático dos 30 Dias divididos em 3 Fases evolutivas.
  List<WorkoutDay> _generateDefault30DayPlan() {
    final List<WorkoutDay> days = [];

    for (int i = 1; i <= 30; i++) {
      String phaseName;
      String title;
      String description;
      int targetJabs;
      int targetCrosses;
      int targetHooks;
      String difficulty;

      if (i <= 10) {
        // FASE 1: Adaptação (Dias 1 a 10)
        phaseName = 'FASE 1 • ADAPTAÇÃO & TÉCNICA';
        difficulty = 'Iniciante';
        targetJabs = 20 + (i * 2);
        targetCrosses = 0;
        targetHooks = 0;
        title = 'Velocidade e Postura de Jab';
        description = 'Ênfase em Jabs controlados, alinhamento de cotovelos e postura de guarda inicial.';
      } else if (i <= 20) {
        // FASE 2: Intensificação (Dias 11 a 20)
        phaseName = 'FASE 2 • INTENSIFICAÇÃO & COMBOS';
        difficulty = 'Intermediário';
        targetJabs = 30;
        targetCrosses = 15 + ((i - 10) * 2);
        targetHooks = 0;
        title = 'Combo Jab + Cross (Direto)';
        description = 'Introdução de combinações de 2 golpes com projeção de ombro traseiro e maior ritmo.';
      } else {
        // FASE 3: Combate Total (Dias 21 a 30)
        phaseName = 'FASE 3 • COMBATE TOTAL';
        difficulty = 'Avançado';
        targetJabs = 35;
        targetCrosses = 25;
        targetHooks = 10 + ((i - 20) * 2);
        title = 'Combos Rápidos com Hook';
        description = 'Sequências de 3 golpes em alta intensidade, rounds estendidos e foco em potência.';
      }

      days.add(
        WorkoutDay(
          dayNumber: i,
          phaseName: phaseName,
          title: title,
          description: description,
          targetJabs: targetJabs,
          targetCrosses: targetCrosses,
          targetHooks: targetHooks,
          durationSeconds: 180,
          isCompleted: i == 1, // Dia 1 concluído como exemplo ou primeiro ativo
          isUnlocked: i <= 2,  // Dias 1 e 2 liberados inicialmente
          difficulty: difficulty,
        ),
      );
    }

    return days;
  }
}
