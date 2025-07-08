
import 'package:flutter/material.dart';
import '../models/plan_data.dart';

class InputModalWidget extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final String title;
  final Function(List<IncomeItem>, double) onComplete;
  final String placeholder;
  final String hintText; // ✅ 항목별 안내 메시지

  const InputModalWidget({
    Key? key,
    required this.isOpen,
    required this.onClose,
    required this.title,
    required this.onComplete,
    this.placeholder = "카테고리명",
    this.hintText = "예: 월급, 아르바이트, 용돈 등", // ✅ 기본 안내문구
  }) : super(key: key);

  @override
  State<InputModalWidget> createState() => _InputModalWidgetState();
}

class _InputModalWidgetState extends State<InputModalWidget> {
  List<IncomeItem> items = [
    IncomeItem(id: '1'),
    IncomeItem(id: '2'),
    IncomeItem(id: '3'),
  ];
  String error = '';

  void addItem() {
    setState(() {
      items.add(IncomeItem(id: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }

  void updateItem(String id, String field, dynamic value) {
    setState(() {
      final index = items.indexWhere((item) => item.id == id);
      if (index != -1) {
        if (field == 'category') {
          items[index].category = value;
        } else if (field == 'amount') {
          items[index].amount = value;
        }
      }
      error = '';
    });
  }

  void removeItem(String id) {
    if (items.length > 1) {
      setState(() {
        items.removeWhere((item) => item.id == id);
      });
    }
  }

  double getTotalAmount() {
    return items.fold(0, (sum, item) => sum + item.amount);
  }

  void handleComplete() {
    final validItems = items.where((item) => item.category.isNotEmpty && item.amount > 0).toList();
    final hasEmptyCategory = items.any((item) => item.amount > 0 && item.category.trim().isEmpty);

    if (hasEmptyCategory) {
      setState(() {
        error = '카테고리명을 정확히 입력해주세요.';
      });
      return;
    }

    if (validItems.isEmpty) {
      setState(() {
        error = '최소 하나의 항목을 입력해주세요.';
      });
      return;
    }

    widget.onComplete(validItems, getTotalAmount());
    widget.onClose();
    setState(() {
      error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (error.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(color: const Color(0xFFFECACA)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            error,
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 14,
                            ),
                          ),
                        ),

                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '항목 ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  if (items.length > 1)
                                    GestureDetector(
                                      onTap: () => removeItem(item.id),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // ✅ 안내 문구 추가
                              Text(
                                '💡월 수입은 이렇게 작성하세요! ${widget.hintText}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 8),

                              TextField(
                                decoration: InputDecoration(
                                  hintText: widget.placeholder,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                                onChanged: (value) => updateItem(item.id, 'category', value),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: '금액',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                                  ),
                                  contentPadding: EdgeInsets.all(12),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => updateItem(item.id, 'amount', double.tryParse(value) ?? 0),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      GestureDetector(
                        onTap: addItem,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20, color: Color(0xFF6B7280)),
                              SizedBox(width: 8),
                              Text(
                                '항목 추가',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '총합:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${getTotalAmount().toStringAsFixed(0)}원',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0062FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: handleComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0062FF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '완료',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
