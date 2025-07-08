import 'package:flutter/material.dart';
import 'dart:async';
import '../models/chat_message.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;

  const ChatMessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with SingleTickerProviderStateMixin {
  String _displayText = '';
  bool _isComplete = false;
  late AnimationController _animationController;
  Timer? _typingTimer;

  // 메시지별로 애니메이션 완료 여부를 기억하는 static Set
  static final Set<String> _completedMessageIds = <String>{};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();

    // 메시지 id가 이미 완료된 목록에 있으면 바로 전체 텍스트 표시
    if (_completedMessageIds.contains(widget.message.id)) {
      _displayText = widget.message.content;
      _isComplete = true;
    } else if (widget.message.type == MessageType.bot && !_isComplete) {
      _startTypingAnimation();
    } else {
      _displayText = widget.message.content;
      _isComplete = true;
    }
  }

  @override
  void didUpdateWidget(covariant ChatMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 메시지 id가 바뀌었을 때만 동작
    if (widget.message.id != oldWidget.message.id) {
      if (_completedMessageIds.contains(widget.message.id)) {
        setState(() {
          _displayText = widget.message.content;
          _isComplete = true;
        });
      } else if (!_isComplete && widget.message.type == MessageType.bot) {
        _startTypingAnimation();
      } else {
        setState(() {
          _displayText = widget.message.content;
          _isComplete = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTypingAnimation() {
    if (_isComplete) return;
    int currentIndex = 0;
    final text = widget.message.content;

    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (currentIndex < text.length) {
        setState(() {
          _displayText = text.substring(0, currentIndex + 1);
        });
        currentIndex++;
      } else {
        setState(() {
          _isComplete = true;
        });
        // 애니메이션이 끝난 메시지 id를 static Set에 저장
        _completedMessageIds.add(widget.message.id);
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBot = widget.message.type == MessageType.bot;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFBFD8FF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🧾', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isBot ? const Color(0xFFF4F4F4) : const Color(0xFF0062FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _displayText,
                style: TextStyle(
                  color: isBot ? const Color(0xFF333333) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
