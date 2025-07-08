
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/plan_data.dart';
import '../models/saving_calculation_result.dart';
import '../services/saving_calculator.dart';
import '../enums/chat_step.dart';

class ChatPlanViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  ChatStep _currentStep = ChatStep.greeting;
  final PlanData _planData = PlanData();
  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  ChatStep get currentStep => _currentStep;
  PlanData get planData => _planData;
  bool get isTyping => _isTyping;

  final List<String> purposeOptions = [
    '여행자금', '자취 준비', '부모님 선물', '결혼 준비', 
    '학자금', '이직준비', '긴급자금', '기타'
  ];

  void addMessage(String content, MessageType type, {bool isTyping = false}) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      content: content,
      timestamp: DateTime.now(),
      isTyping: isTyping,
    );
    
    _messages.add(newMessage);
    notifyListeners();
  }

  Future<void> addBotMessageWithTyping(String content, {int delay = 1000}) async {
    _isTyping = true;
    notifyListeners();
    
    await Future.delayed(Duration(milliseconds: delay));
    
    addMessage(content, MessageType.bot);
    _isTyping = false;
    notifyListeners();
  }

  void updatePlanData({
    String? planName,
    String? purpose,
    double? targetAmount,
    double? currentAsset,
    double? monthlyIncome,
    double? monthlyFixedCost,
    double? dailySpendingLimit,
  }) {
    if (planName != null) _planData.planName = planName;
    if (purpose != null) _planData.purpose = purpose;
    if (targetAmount != null) _planData.targetAmount = targetAmount;
    if (currentAsset != null) _planData.currentAsset = currentAsset;
    if (monthlyIncome != null) _planData.monthlyIncome = monthlyIncome;
    if (monthlyFixedCost != null) _planData.monthlyFixedCost = monthlyFixedCost;
    if (dailySpendingLimit != null) _planData.dailySpendingLimit = dailySpendingLimit;
    
    notifyListeners();
  }

  void nextStep() {
    final steps = ChatStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    
    if (currentIndex < steps.length - 1) {
      _currentStep = steps[currentIndex + 1];
      notifyListeners();
    }
  }

  Future<void> handleUserResponse(String response) async {
    addMessage(response, MessageType.user);
    
    switch (_currentStep) {
      case ChatStep.greeting:
        if (response == '좋아요! 시작할게요') {
          await addBotMessageWithTyping('먼저 이 플랜에 이름을 붙여볼게요!\n예: 🏝여름휴가 프로젝트 / 🎓학자금 모으기 등');
          nextStep();
        }
        break;
        
      case ChatStep.planName:
        updatePlanData(planName: response);
        await addBotMessageWithTyping('이 플랜의 목적은 무엇인가요?\n아래 카드 중 하나를 선택해주세요.');
        nextStep();
        break;
        
      case ChatStep.purpose:
        updatePlanData(purpose: response);
        await addBotMessageWithTyping('좋아요! 이번 플랜의 목표 금액은 얼마인가요?');
        nextStep();
        break;
        
      case ChatStep.targetAmount:
        updatePlanData(targetAmount: double.tryParse(response) ?? 0);
        await addBotMessageWithTyping('현재 가지고 계신 자산이 있으신가요?\n(예: 통장 잔고 등)');
        nextStep();
        break;
        
      case ChatStep.currentAsset:
        if (response == '있어요') {
          await addBotMessageWithTyping('지금 보유 중인 금액을 입력해주세요.');
          _currentStep = ChatStep.currentAssetConfirm;
          notifyListeners();
        } else {
          updatePlanData(currentAsset: 0);
          await addBotMessageWithTyping('다음은 월 수입이에요.\n버튼을 눌러 다양한 수입 항목을 입력해주세요!\n\n💬 소통 Tip💡!\n수입원이 여러 개라면 합산해주시고,\n불규칙하다면 최근 3개월 평균으로 입력해주세요.');
          nextStep();
        }
        break;
        
      case ChatStep.currentAssetConfirm:
        updatePlanData(currentAsset: double.tryParse(response) ?? 0);
        await addBotMessageWithTyping('다음은 월 수입이에요.\n버튼을 눌러 다양한 수입 항목을 입력해주세요!');
        nextStep();
        break;

      case ChatStep.summary:
        await addBotMessageWithTyping('마지막으로, 소통 자동등록 서비스를 활성화해드릴까요?\n\n💡 자동등록 서비스란?\n소통 어플에 출석하지 않고 소비를 기록하지 못한 날,\n설정한 하루 소비 한도 금액을 자동으로 반영해주는 기능이에요.\n잊어버려도 플랜은 계속 진행되도록 도와줘요!');
        nextStep();
        break;

      case ChatStep.autoService:
        if (response == '네! 좋아요') {
          await addBotMessageWithTyping('완료되었습니다! 🎉\n이제 홈화면에서 매일 소비 기록을 하거나,\n소통 자동등록으로 계획을 이어가실 수 있어요.\n함께 멋진 목표를 완성해봐요, 인수님! 🚀');
          nextStep();
        }
        break;
      
      default:
        break;
    }
  }

  SavingCalculationResult? calculatePlan() {
    if (_planData.monthlyIncome > 0 && 
        _planData.monthlyFixedCost > 0 && 
        _planData.targetAmount > 0 && 
        _planData.dailySpendingLimit > 0) {
      
      final calculator = SavingPlanCalculator.fromPlanData(_planData);
      return calculator.calculate();
    }
    return null;
  }

  Future<void> initializeChat() async {
    await addBotMessageWithTyping(
      '안녕하세요, 인수님! 🎯\n소통 어플은 "오늘의 소비"만으로 목표 금액을 완성하는 맞춤형 재정 플랜을 설계해드려요.\n저와 함께 단계별로 하나씩 만들어볼까요?',
      delay: 500
    );
  }
}
