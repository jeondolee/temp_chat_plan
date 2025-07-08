import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_plan_viewmodel.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/purpose_selector_widget.dart';
import '../widgets/input_modal_widget.dart';
import '../widgets/plan_summary_chart_widget.dart';
import '../enums/chat_step.dart';
import '../services/saving_calculator.dart';

class ChatPlanPage extends StatefulWidget {
  const ChatPlanPage({Key? key}) : super(key: key);

  @override
  State<ChatPlanPage> createState() => _ChatPlanPageState();
}

class _ChatPlanPageState extends State<ChatPlanPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showIncomeModal = false;
  bool _showFixedCostModal = false;
  bool _showDailySpendingModal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ChatPlanViewModel>(context, listen: false);
      if (viewModel.messages.isEmpty) {
        viewModel.initializeChat();
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_inputController.text.trim().isNotEmpty) {
      final viewModel = Provider.of<ChatPlanViewModel>(context, listen: false);
      viewModel.handleUserResponse(_inputController.text);
      _inputController.clear();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatAmountGuide(double amount, String type) {
    if (amount > 0) {
      return '$type은 ${SavingPlanCalculator.formatAmount(amount)}원이에요!';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ChatPlanViewModel>(
        builder: (context, viewModel, child) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
          return Stack(
            children: [
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF0F0F0)),
                        ),
                      ),
                      child: const Text(
                        '플랜 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Chat Messages
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          ...viewModel.messages
                              .map((message) =>
                                  ChatMessageWidget(message: message))
                              .toList(),

                          // Amount Guide
                          if ((viewModel.currentStep == ChatStep.targetAmount ||
                                  viewModel.currentStep ==
                                      ChatStep.currentAssetConfirm) &&
                              _inputController.text.isNotEmpty &&
                              double.tryParse(_inputController.text) != null &&
                              double.parse(_inputController.text) > 0)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  viewModel.currentStep == ChatStep.targetAmount
                                      ? _formatAmountGuide(
                                          double.parse(_inputController.text),
                                          '목표금액')
                                      : _formatAmountGuide(
                                          double.parse(_inputController.text),
                                          '보유금액'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ),
                            ),

                          // Purpose Selector
                          if (viewModel.currentStep == ChatStep.purpose)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: PurposeSelectorWidget(
                                options: viewModel.purposeOptions,
                                onSelect: viewModel.handleUserResponse,
                              ),
                            ),

                          // Action Buttons
                          if (viewModel.currentStep == ChatStep.monthlyIncome)
                            Center(
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => _showIncomeModal = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0062FF),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '월 수입 입력하러가기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          if (viewModel.currentStep ==
                              ChatStep.monthlyFixedCost)
                            Center(
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => _showFixedCostModal = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0062FF),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '고정 소비 입력하러가기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          if (viewModel.currentStep == ChatStep.dailySpending)
                            Center(
                              child: ElevatedButton(
                                onPressed: () => setState(
                                    () => _showDailySpendingModal = true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0062FF),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '하루 소비 한도 금액 입력하러가기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          // Plan Summary Chart
                          if (viewModel.currentStep == ChatStep.summary &&
                              viewModel.calculatePlan() != null)
                            Column(
                              children: [
                                PlanSummaryChartWidget(
                                  calculation: viewModel.calculatePlan()!,
                                  monthlyIncome:
                                      viewModel.planData.monthlyIncome,
                                  monthlyFixedCost:
                                      viewModel.planData.monthlyFixedCost,
                                  dailySpendingLimit:
                                      viewModel.planData.dailySpendingLimit,
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        viewModel.handleUserResponse('다음 단계로'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0062FF),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '다음 단계로',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          // Current Asset Buttons
                          if (viewModel.currentStep == ChatStep.currentAsset)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      viewModel.handleUserResponse('있어요'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0062FF),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    '✅ 있어요',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () =>
                                      viewModel.handleUserResponse('없어요'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B7280),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    '🚫 없어요',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),

                          // Typing Indicator
                          if (viewModel.isTyping)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFBFD8FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('🧾',
                                          style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F4F4),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF9CA3AF),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF9CA3AF),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF9CA3AF),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Input Area
                    if (viewModel.currentStep == ChatStep.planName ||
                        viewModel.currentStep == ChatStep.targetAmount ||
                        viewModel.currentStep == ChatStep.currentAssetConfirm)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border:
                              Border(top: BorderSide(color: Color(0xFFF0F0F0))),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _inputController,
                                keyboardType: viewModel.currentStep ==
                                            ChatStep.targetAmount ||
                                        viewModel.currentStep ==
                                            ChatStep.currentAssetConfirm
                                    ? TextInputType.number
                                    : TextInputType.text,
                                decoration: InputDecoration(
                                  hintText:
                                      viewModel.currentStep == ChatStep.planName
                                          ? '플랜 이름을 입력하세요'
                                          : viewModel.currentStep ==
                                                  ChatStep.targetAmount
                                              ? '목표 금액을 입력하세요'
                                              : '보유 금액을 입력하세요',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD1D5DB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF3B82F6), width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                                onChanged: (value) => setState(() {}),
                                onSubmitted: (_) => _handleSubmit(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0062FF),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '전송',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Bottom Fixed Buttons
                    if (viewModel.currentStep == ChatStep.greeting)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border:
                              Border(top: BorderSide(color: Color(0xFFF0F0F0))),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                viewModel.handleUserResponse('좋아요! 시작할게요'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0062FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '네, 좋아요!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Auto Service Buttons
                    if (viewModel.currentStep == ChatStep.autoService)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border:
                              Border(top: BorderSide(color: Color(0xFFF0F0F0))),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                viewModel.handleUserResponse('네! 좋아요'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0062FF),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '🟢 네! 좋아요',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Modals
              InputModalWidget(
                isOpen: _showIncomeModal,
                onClose: () => setState(() => _showIncomeModal = false),
                title: '월 수입 입력하기',
                placeholder: '수입 카테고리',
                onComplete: (items, total) {
                  final viewModel =
                      Provider.of<ChatPlanViewModel>(context, listen: false);
                  viewModel.updatePlanData(monthlyIncome: total);
                  viewModel.addBotMessageWithTyping(
                      '입력 완료! 인수님의 총 월 수입은 ${SavingPlanCalculator.formatAmount(total)}원으로 등록되었어요. 😊\n\n이번엔 매달 꼭 나가는 고정 소비를 입력해주세요.\n(예: 월세, 통신비, 교통비, 구독료 등)\n\n💬 고정소비란?\n반복적으로 소비되는 생활 필수비용이에요.\n\n💬 소통 Tip💡!\n저축(적금, 펀드 등)은 고정지출이 아니라 따로 계산돼요!\n여기에는 실생활 유지 비용만 입력해주세요. 😊');
                  viewModel.nextStep();
                },
              ),

              InputModalWidget(
                isOpen: _showFixedCostModal,
                onClose: () => setState(() => _showFixedCostModal = false),
                title: '고정 소비 입력하기',
                placeholder: '고정 지출 항목',
                onComplete: (items, total) {
                  final viewModel =
                      Provider.of<ChatPlanViewModel>(context, listen: false);
                  viewModel.updatePlanData(monthlyFixedCost: total);
                  viewModel.addBotMessageWithTyping(
                      '고정 소비 등록 완료!\n총 고정 소비는 ${SavingPlanCalculator.formatAmount(total)}원이에요.\n\n이제 하루에 얼마까지 쓸지 정해볼게요!\n하루 소비한도금액 항목(식비, 여가비 등)을 입력해주세요.');
                  viewModel.nextStep();
                },
              ),

              InputModalWidget(
                isOpen: _showDailySpendingModal,
                onClose: () => setState(() => _showDailySpendingModal = false),
                title: '하루 소비 한도 금액',
                placeholder: '소비 항목',
                onComplete: (items, total) {
                  final viewModel =
                      Provider.of<ChatPlanViewModel>(context, listen: false);
                  viewModel.updatePlanData(dailySpendingLimit: total);
                  final monthlyVariable = total * 30;
                  viewModel.addBotMessageWithTyping(
                      '하루 소비 한도는 ${SavingPlanCalculator.formatAmount(total)}원,\n→ 월 변동 소비 금액은 ${SavingPlanCalculator.formatAmount(monthlyVariable)}원으로 계산되었어요.');

                  Future.delayed(const Duration(milliseconds: 2000), () {
                    viewModel.nextStep();
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
