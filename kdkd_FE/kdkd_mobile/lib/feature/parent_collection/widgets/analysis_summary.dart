import 'package:flutter/material.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';

class AnalysisSummary extends StatelessWidget {
  final UiState<String> aiFeedbackState;

  const AnalysisSummary({super.key, required this.aiFeedbackState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(38, 128, 128, 128),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.blueAccent,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: aiFeedbackState.when(
              idle: () => const Text(
                'AI 분석을 불러오는 중...',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              loading: () => const Text(
                'AI 분석을 불러오는 중...',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              success: (feedback, isFallback, fromCache) => Text(
                feedback,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              failure: (error, message) => const Text(
                '지난 주에 비해 쇼핑 지출이 15% 늘었어요. 현명한 소비 습관을 길러봐요!',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}