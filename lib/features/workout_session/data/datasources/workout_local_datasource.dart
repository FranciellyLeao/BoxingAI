import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../profile/domain/entities/athlete_profile.dart';
import '../../domain/entities/workout_session.dart';

/// Datasource local responsável pela persistência offline das sessões de treino e perfil do atleta.
class WorkoutLocalDataSource {
  static const String _profileKey = 'cyber_boxing_athlete_profile';
  static const String _sessionsKey = 'cyber_boxing_sessions_history';

  /// Carrega o perfil do atleta. Se não existir no dispositivo, cria o perfil inicial.
  Future<AthleteProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_profileKey);

    if (profileJson == null) {
      final initialProfile = AthleteProfile.initial();
      await saveProfile(initialProfile);
      return initialProfile;
    }

    try {
      final Map<String, dynamic> map = jsonDecode(profileJson);
      return AthleteProfile.fromJson(map);
    } catch (_) {
      return AthleteProfile.initial();
    }
  }

  /// Salva o perfil do atleta no armazenamento do dispositivo.
  Future<void> saveProfile(AthleteProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  /// Registra uma nova sessão de treino e calcula a atualização do Streak e do XP ganho.
  Future<WorkoutSessionResult> recordWorkoutSession({
    required int jabsCount,
    required int durationSeconds,
    required double precisionPercentage,
  }) async {
    final currentProfile = await getProfile();
    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    // 1. Cálculo de XP Ganho
    final int baseJabXP = jabsCount * 10;
    final int precisionBonus = (precisionPercentage * 2).toInt();
    final int roundBonus = 100;
    final int xpEarned = baseJabXP + precisionBonus + roundBonus;

    // 2. Atualização Automática de Streak de Ofensiva
    final int newStreak = _calculateUpdatedStreak(
      currentStreak: currentProfile.streakDays,
      lastWorkoutTimestamp: currentProfile.lastWorkoutTimestamp,
      nowTimestamp: nowMs,
    );

    // 3. Atualiza Perfil
    final updatedProfile = currentProfile.copyWith(
      totalJabs: currentProfile.totalJabs + jabsCount,
      totalWorkouts: currentProfile.totalWorkouts + 1,
      totalXP: currentProfile.totalXP + xpEarned,
      streakDays: newStreak,
      lastWorkoutTimestamp: nowMs,
    );

    await saveProfile(updatedProfile);

    // 4. Cria e salva o registro histórico da sessão
    final session = WorkoutSession(
      id: 'session_$nowMs',
      timestamp: nowMs,
      durationSeconds: durationSeconds,
      jabsCount: jabsCount,
      precisionPercentage: precisionPercentage,
      xpEarned: xpEarned,
    );

    final prefs = await SharedPreferences.getInstance();
    final List<String> historyList = prefs.getStringList(_sessionsKey) ?? [];
    historyList.add(jsonEncode(session.toJson()));
    await prefs.setStringList(_sessionsKey, historyList);

    return WorkoutSessionResult(
      session: session,
      updatedProfile: updatedProfile,
    );
  }

  /// Algoritmo de cálculo de dias de Streak consecutivos.
  int _calculateUpdatedStreak({
    required int currentStreak,
    required int? lastWorkoutTimestamp,
    required int nowTimestamp,
  }) {
    if (lastWorkoutTimestamp == null) return 1;

    final DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastWorkoutTimestamp);
    final DateTime nowDate = DateTime.fromMillisecondsSinceEpoch(nowTimestamp);

    final DateTime lastDayOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final DateTime nowDayOnly = DateTime(nowDate.year, nowDate.month, nowDate.day);

    final int differenceInDays = nowDayOnly.difference(lastDayOnly).inDays;

    if (differenceInDays == 0) {
      // Treinou hoje novamente: mantém a ofensiva
      return currentStreak;
    } else if (differenceInDays == 1) {
      // Treinou no dia seguinte: avança o streak em +1
      return currentStreak + 1;
    } else {
      // Ficou 2 ou mais dias sem treinar: reinicia o streak para 1 dia
      return 1;
    }
  }
}

class WorkoutSessionResult {
  final WorkoutSession session;
  final AthleteProfile updatedProfile;

  WorkoutSessionResult({
    required this.session,
    required this.updatedProfile,
  });
}
