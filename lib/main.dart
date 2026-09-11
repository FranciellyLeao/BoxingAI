import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/storage/isar_database_service.dart';
import 'core/theme/cyber_boxing_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização assíncrona limpa do Banco de Dados 100% Local Isar DB
  await IsarDatabaseService.instance.initialize();

  // Trava a orientação da tela em modo retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Transparência na barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BoxingAIApp());
}

class BoxingAIApp extends StatelessWidget {
  const BoxingAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boxing AI - Cyber Boxing',
      debugShowCheckedModeBanner: false,
      theme: CyberBoxingTheme.themeData,
      home: const HomeScreen(),
    );
  }
}
