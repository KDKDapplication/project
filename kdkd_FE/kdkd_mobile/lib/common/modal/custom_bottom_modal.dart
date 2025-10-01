import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

class CustomBottomModal extends StatelessWidget {
  final Widget child;
  final VoidCallback onConfirm;
  final String confirmText;

  const CustomBottomModal({super.key, required this.child, required this.onConfirm, required this.confirmText});

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required VoidCallback onConfirm,
    required String confirmText,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => CustomBottomModal(onConfirm: onConfirm, confirmText: confirmText, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - keyboardHeight - MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: availableHeight * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 내용 영역 (스크롤 가능)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [child],
                  ),
                ),
              ),

              //  하단 버튼 영역
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  onPressed: () {
                    onConfirm();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      confirmText,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
