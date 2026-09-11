import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/storage/data/models/athlete_profile_model.dart';
import '../../features/storage/data/models/workout_progress_model.dart';
import '../../features/storage/data/models/workout_session_model.dart';

/// Serviço Singleton para gerenciamento do Banco de Dados 100% Local Isar DB.
class IsarDatabaseService {
  static final IsarDatabaseService instance = IsarDatabaseService._internal();
  Isar? _isar;

  IsarDatabaseService._internal();

  Isar? get isar => _isar;
  bool get isInitialized => _isar != null && _isar!.isOpen;

  /// Inicializa o banco de dados Isar assincronamente sem travar a UI ou o Splash Screen.
  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();

      _isar = await Isar.open(
        [
          WorkoutProgressModelSchema,
          AthleteProfileModelSchema,
          WorkoutSessionModelSchema,
        ],
        directory: dir.path,
        name: 'boxing_ai_local_db',
        inspector: kDebugMode,
      );
    } catch (e) {
      debugPrint('Isar DB Initialization Note: $e');
    }
  }

  /// Limpa e fecha a instância do Isar se necessário.
  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}
