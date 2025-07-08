
class SavingCalculationResult {
  final double monthlySaving;
  final double dailySaving;
  final double savingRatio;
  final double dailyNetSaving;
  final double requiredSaving;
  final double daysToGoal;
  final int totalSeconds;
  final DateTime goalDateTime;
  final double savingPerSecond;

  SavingCalculationResult({
    required this.monthlySaving,
    required this.dailySaving,
    required this.savingRatio,
    required this.dailyNetSaving,
    required this.requiredSaving,
    required this.daysToGoal,
    required this.totalSeconds,
    required this.goalDateTime,
    required this.savingPerSecond,
  });
}
