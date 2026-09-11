import 'package:flutter/material.dart';

import '../../../../core/theme/cyber_boxing_theme.dart';
import '../../domain/entities/punch_metrics.dart';
import '../../domain/entities/punch_type.dart';
import '../controllers/punch_detector_notifier.dart';

/// HUD Flutuante com Design System Cyber-Boxing e Telemetria Tríplice de Golpes (Jab, Cross, Hook).
class PunchDashboardOverlay extends StatelessWidget {
  final PunchMetrics metrics;
  final double fps;
  final RoundStatus roundStatus;
  final int remainingSeconds;
  final bool hasRecentHit;
  final VoidCallback onPauseToggle;
  final VoidCallback onReset;
  final VoidCallback onBackPressed;

  const PunchDashboardOverlay({
    super.key,
    required this.metrics,
    required this.fps,
    required this.roundStatus,
    required this.remainingSeconds,
    required this.hasRecentHit,
    required this.onPauseToggle,
    required this.onReset,
    required this.onBackPressed,
  });

  String _formatTimer(int seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getPunchColor(PunchType punchType) {
    switch (punchType) {
      case PunchType.jab:
        return CyberBoxingTheme.neonGreen;
      case PunchType.cross:
        return Colors.orangeAccent;
      case PunchType.hook:
        return CyberBoxingTheme.neonPink;
      default:
        return CyberBoxingTheme.neonGreen;
    }
  }

  String _getPunchBannerText(PunchType punchType) {
    switch (punchType) {
      case PunchType.jab:
        return '⚡ JAB DETECTADO! ⚡';
      case PunchType.cross:
        return '🔥 CROSS / DIRETO! 🔥';
      case PunchType.hook:
        return '💥 HOOK / CRUZADO! 💥';
      default:
        return '⚡ GOLPE DETECTADO! ⚡';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHitActive = metrics.activePunchType != PunchType.none || hasRecentHit;
    final Color punchAccentColor = _getPunchColor(metrics.activePunchType);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // BARRA SUPERIOR: Botão Voltar + Timer do Round + Badge de FPS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBackPressed,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: CyberBoxingTheme.surfaceCard.withOpacity(0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: CyberBoxingTheme.surfaceCardBorder),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  ),
                ),

                // Timer de Round com estilo Cyber Neon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: CyberBoxingTheme.surfaceCard.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: roundStatus == RoundStatus.inProgress
                          ? CyberBoxingTheme.neonGreen
                          : CyberBoxingTheme.neonPink,
                      width: 1.5,
                    ),
                    boxShadow: roundStatus == RoundStatus.inProgress ? CyberBoxingTheme.neonGlow : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        roundStatus == RoundStatus.inProgress ? Icons.timer : Icons.pause_circle_outline,
                        color: roundStatus == RoundStatus.inProgress
                            ? CyberBoxingTheme.neonGreen
                            : CyberBoxingTheme.neonPink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ROUND 1 • ${_formatTimer(remainingSeconds)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.black,
                          fontSize: 16,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Medidor de FPS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: CyberBoxingTheme.surfaceCard.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: CyberBoxingTheme.surfaceCardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed,
                        color: fps >= 25 ? CyberBoxingTheme.neonGreen : CyberBoxingTheme.neonPink,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${fps.toInt()} FPS',
                        style: TextStyle(
                          color: fps >= 25 ? CyberBoxingTheme.neonGreen : CyberBoxingTheme.neonPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // CENTRO DA TELA: Banner Animado do Golpe Desferido (Jab, Cross ou Hook)
            if (isHitActive)
              AnimatedScale(
                scale: hasRecentHit ? 1.25 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: punchAccentColor,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: punchAccentColor.withOpacity(0.8),
                        blurRadius: 30,
                        spreadRadius: 6,
                      )
                    ],
                  ),
                  child: Text(
                    _getPunchBannerText(metrics.activePunchType),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.black,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
              ),

            // BARRA INFERIOR: HUD TRÍPLICE COM JAB, CROSS E HOOK
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: CyberBoxingTheme.surfaceCard.withOpacity(0.92),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: CyberBoxingTheme.surfaceCardBorder, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contadores Tríplices (Jabs, Crosses, Hooks)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _PunchCounterBadge(
                        label: 'JABS',
                        count: metrics.totalJabsCount,
                        accentColor: CyberBoxingTheme.neonGreen,
                      ),
                      _PunchCounterBadge(
                        label: 'CROSSES',
                        count: metrics.totalCrossesCount,
                        accentColor: Colors.orangeAccent,
                      ),
                      _PunchCounterBadge(
                        label: 'HOOKS',
                        count: metrics.totalHooksCount,
                        accentColor: CyberBoxingTheme.neonPink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: CyberBoxingTheme.surfaceCardBorder, height: 1),
                  const SizedBox(height: 10),

                  // Telemetria do Braço Esquerdo
                  _ArmMetricRow(
                    label: 'BRAÇO ESQUERDO',
                    angle: metrics.leftElbowAngle,
                    extensionRatio: metrics.leftArmExtensionRatio,
                    accentColor: CyberBoxingTheme.neonGreen,
                  ),
                  const SizedBox(height: 6),

                  // Telemetria do Braço Direito
                  _ArmMetricRow(
                    label: 'BRAÇO DIREITO',
                    angle: metrics.rightElbowAngle,
                    extensionRatio: metrics.rightArmExtensionRatio,
                    accentColor: CyberBoxingTheme.neonCyan,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PunchCounterBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color accentColor;

  const _PunchCounterBadge({
    required this.label,
    required this.count,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArmMetricRow extends StatelessWidget {
  final String label;
  final double angle;
  final double extensionRatio;
  final Color accentColor;

  const _ArmMetricRow({
    required this.label,
    required this.angle,
    required this.extensionRatio,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (extensionRatio * 100).clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: CyberBoxingTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${angle.toStringAsFixed(0)}° • ${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: extensionRatio.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            color: accentColor,
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
