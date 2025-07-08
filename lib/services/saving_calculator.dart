
import '../models/plan_data.dart';
import '../models/saving_calculation_result.dart';

class SavingPlanCalculator {
  final double monthlyIncome;
  final double monthlyFixedCost;
  final double targetAmount;
  final double currentAsset;
  final double dailySpendingLimit;
  final DateTime planStartDate;

  SavingPlanCalculator({
    required this.monthlyIncome,
    required this.monthlyFixedCost,
    required this.targetAmount,
    required this.currentAsset,
    required this.dailySpendingLimit,
    required this.planStartDate,
  });

  factory SavingPlanCalculator.fromPlanData(PlanData planData) {
    return SavingPlanCalculator(
      monthlyIncome: planData.monthlyIncome,
      monthlyFixedCost: planData.monthlyFixedCost,
      targetAmount: planData.targetAmount,
      currentAsset: planData.currentAsset,
      dailySpendingLimit: planData.dailySpendingLimit,
      planStartDate: planData.planStartDate,
    );
  }

  SavingCalculationResult calculate() {
    final monthlySaving = monthlyIncome - monthlyFixedCost;
    final dailySaving = monthlySaving / 30;
    final savingRatio = 1 - (dailySpendingLimit / dailySaving);
    final dailyNetSaving = dailySaving - dailySpendingLimit;
    final requiredSaving = targetAmount - currentAsset;
    final daysToGoal = requiredSaving / dailyNetSaving;
    final totalSeconds = (daysToGoal * 86400).round();
    final goalDateTime = planStartDate.add(Duration(seconds: totalSeconds));
    final savingPerSecond = dailyNetSaving / 86400;

    return SavingCalculationResult(
      monthlySaving: monthlySaving,
      dailySaving: dailySaving,
      savingRatio: savingRatio,
      dailyNetSaving: dailyNetSaving,
      requiredSaving: requiredSaving,
      daysToGoal: daysToGoal,
      totalSeconds: totalSeconds,
      goalDateTime: goalDateTime,
      savingPerSecond: savingPerSecond,
    );
  }

  static String formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
