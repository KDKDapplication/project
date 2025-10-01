import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_main/providers/connection_code_provider.dart';

class ParentMainCreateCodePage extends ConsumerStatefulWidget {
  const ParentMainCreateCodePage({super.key});

  @override
  ConsumerState<ParentMainCreateCodePage> createState() => _ParentMainCreateCodePageState();
}

class _ParentMainCreateCodePageState extends ConsumerState<ParentMainCreateCodePage> {
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(connectionCodeProvider.notifier).generateCode();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int initialSeconds) {
    _timer?.cancel();
    _remainingSeconds = initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            // 시간이 만료되면 새로운 코드 생성
            ref.read(connectionCodeProvider.notifier).generateCode();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final codeState = ref.watch(connectionCodeProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: "자녀등록",
        useBackspace: true,
        actionType: AppBarActionType.none,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppConst.padding),
        child: codeState.when(
          idle: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (codeModel, isFallback, fromCache) => _buildSuccessContent(codeModel),
          failure: (error, message) => _buildErrorContent(),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(codeModel) {
    // 새로운 코드가 생성되면 타이머 시작
    if (_remainingSeconds == 0 || _remainingSeconds > codeModel.ttlSeconds) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer(codeModel.ttlSeconds);
      });
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("부모 코드", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text(
            "만료시간: ${_formatRemainingTime(_remainingSeconds > 0 ? _remainingSeconds : codeModel.ttlSeconds)}",
            style: TextStyle(
              fontSize: 14,
              color: _remainingSeconds <= 30 ? Colors.red : Colors.grey,
              fontWeight: _remainingSeconds <= 30 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: codeModel.code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("복사되었습니다!")),
              );
            },
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.grayBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      codeModel.code,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -1.5),
                      textAlign: TextAlign.center,
                    ),
                    SvgPicture.asset('assets/svgs/copy.svg', width: 24, height: 24),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          const Text(
            "자녀 앱에서 부모 코드를 입력하시면\n자동으로 연동됩니다.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "코드 생성에 실패했습니다",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(connectionCodeProvider.notifier).generateCode();
            },
            child: const Text("다시 시도"),
          ),
        ],
      ),
    );
  }

  String _formatRemainingTime(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return "$minutes분 $remainingSeconds초";
  }
}
