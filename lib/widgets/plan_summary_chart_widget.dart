
import 'package:flutter/material.dart';
import '../models/saving_calculation_result.dart';
import '../services/saving_calculator.dart';

class PlanSummaryChartWidget extends StatelessWidget {
  final SavingCalculationResult calculation;
  final double monthlyIncome;
  final double monthlyFixedCost;
  final double dailySpendingLimit;

  const PlanSummaryChartWidget({
    Key? key,
    required this.calculation,
    required this.monthlyIncome,
    required this.monthlyFixedCost,
    required this.dailySpendingLimit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthlyVariableCost = dailySpendingLimit * 30;
    final monthlySaving = calculation.monthlySaving - monthlyVariableCost;

    final fixedRatio = (monthlyFixedCost / monthlyIncome);
    final variableRatio = (monthlyVariableCost / monthlyIncome);
    final savingRatio = (monthlySaving / monthlyIncome);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 한눈에 보는 플랜 요약',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          
          // Chart Bar
          Container(
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (fixedRatio * 100).round(),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF87171),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: (variableRatio * 100).round(),
                  child: Container(
                    color: const Color(0xFFFB923C),
                  ),
                ),
                Expanded(
                  flex: (savingRatio * 100).round(),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Legend
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF87171),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '고정소비: ${SavingPlanCalculator.formatAmount(monthlyFixedCost)}원',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB923C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '변동소비: ${SavingPlanCalculator.formatAmount(monthlyVariableCost)}원',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '저축: ${SavingPlanCalculator.formatAmount(monthlySaving)}원',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: Text(
              '💬 전체 월 수입: ${SavingPlanCalculator.formatAmount(monthlyIncome)}원',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '🎯 하루 저축 가능 금액',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${SavingPlanCalculator.formatAmount(calculation.dailyNetSaving)}원',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '⏱ 1초당 약 ${calculation.savingPerSecond.toStringAsFixed(2)}원 저축',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
