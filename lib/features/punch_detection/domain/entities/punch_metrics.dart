import 'punch_type.dart';

/// Métricas biométricas e contadores individuais dos 3 golpes (Jab, Cross, Hook).
class PunchMetrics {
  final double leftElbowAngle;
  final double rightElbowAngle;
  final double leftArmExtensionRatio;
  final double rightArmExtensionRatio;
  final PunchType activePunchType;
  final bool isPunchPeakDetected;
  final int totalJabsCount;
  final int totalCrossesCount;
  final int totalHooksCount;

  const PunchMetrics({
    required this.leftElbowAngle,
    required this.rightElbowAngle,
    required this.leftArmExtensionRatio,
    required this.rightArmExtensionRatio,
    required this.activePunchType,
    required this.isPunchPeakDetected,
    required this.totalJabsCount,
    required this.totalCrossesCount,
    required this.totalHooksCount,
  });

  int get totalPunchesCount => totalJabsCount + totalCrossesCount + totalHooksCount;

  factory PunchMetrics.initial() => const PunchMetrics(
        leftElbowAngle: 0.0,
        rightElbowAngle: 0.0,
        leftArmExtensionRatio: 0.0,
        rightArmExtensionRatio: 0.0,
        activePunchType: PunchType.none,
        isPunchPeakDetected: false,
        totalJabsCount: 0,
        totalCrossesCount: 0,
        totalHooksCount: 0,
      );

  PunchMetrics copyWith({
    double? leftElbowAngle,
    double? rightElbowAngle,
    double? leftArmExtensionRatio,
    double? rightArmExtensionRatio,
    PunchType? activePunchType,
    bool? isPunchPeakDetected,
    int? totalJabsCount,
    int? totalCrossesCount,
    int? totalHooksCount,
  }) {
    return PunchMetrics(
      leftElbowAngle: leftElbowAngle ?? this.leftElbowAngle,
      rightElbowAngle: rightElbowAngle ?? this.rightElbowAngle,
      leftArmExtensionRatio: leftArmExtensionRatio ?? this.leftArmExtensionRatio,
      rightArmExtensionRatio: rightArmExtensionRatio ?? this.rightArmExtensionRatio,
      activePunchType: activePunchType ?? this.activePunchType,
      isPunchPeakDetected: isPunchPeakDetected ?? this.isPunchPeakDetected,
      totalJabsCount: totalJabsCount ?? this.totalJabsCount,
      totalCrossesCount: totalCrossesCount ?? this.totalCrossesCount,
      totalHooksCount: totalHooksCount ?? this.totalHooksCount,
    );
  }
}
