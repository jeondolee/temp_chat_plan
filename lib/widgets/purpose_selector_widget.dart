
import 'package:flutter/material.dart';

class PurposeSelectorWidget extends StatelessWidget {
  final List<String> options;
  final Function(String) onSelect;

  const PurposeSelectorWidget({
    Key? key,
    required this.options,
    required this.onSelect,
  }) : super(key: key);

  static const Map<String, String> purposeEmojiMap = {
    '여행자금': '✈️',
    '자취 준비': '🏠',
    '부모님 선물': '🎁',
    '결혼 준비': '💒',
    '학자금': '🎓',
    '이직준비': '💼',
    '긴급자금': '🚨',
    '기타': '💡'
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final purpose = options[index];
          return Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => onSelect(purpose),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFBFD8FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFADCCFF),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      purposeEmojiMap[purpose] ?? '💡',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      purpose,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00368C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
