import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

enum PopupType { zero, one, two, completeAndDelete }

class CustomPopupModal extends StatelessWidget {
  final Widget child;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? confirmText2;
  final VoidCallback? onConfirm2;
  final Color? buttonType;
  final PopupType popupType;

  const CustomPopupModal({
    super.key,
    required this.child,
    required this.onConfirm,
    required this.confirmText,
    this.buttonType = AppColors.primary,
    this.popupType = PopupType.one,
    this.confirmText2,
    this.onConfirm2,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required VoidCallback onConfirm,
    required String confirmText,
    Color? buttonType,
    PopupType popupType = PopupType.one,
    String? confirmText2,
    VoidCallback? onConfirm2,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CustomPopupModal(
        onConfirm: onConfirm,
        confirmText: confirmText,
        buttonType: buttonType,
        popupType: popupType,
        confirmText2: confirmText2,
        onConfirm2: onConfirm2,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget button;

    if (popupType == PopupType.one) {
      button = SizedBox(
        width: 120,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonType ?? AppColors.mint,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black,
          ),
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
      );
    } else if (popupType == PopupType.two) {
      button = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 4,
              shadowColor: Colors.black,
            ),
            onPressed: onConfirm,
            child: Text(confirmText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              foregroundColor: AppColors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 4,
              shadowColor: Colors.black,
            ),
            onPressed: onConfirm2 ?? () {},
            child: Text(confirmText2 ?? ""),
          ),
        ],
      );
    } else if (popupType == PopupType.completeAndDelete) {
      button = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redError,
              foregroundColor: AppColors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 4,
              shadowColor: Colors.black,
            ),
            onPressed: onConfirm,
            child: Text(confirmText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: AppColors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 4,
              shadowColor: Colors.black,
            ),
            onPressed: onConfirm2 ?? () {},
            child: Text(confirmText2 ?? ""),
          ),
        ],
      );
    } else {
      button = SizedBox(
        width: 120,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonType ?? AppColors.redError,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black,
          ),
          onPressed: () {},
          child: Text('닫기'),
        ),
      );
    }

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(height: 20),
              button,
            ],
          ),
        ),
      ),
    );
  }
}
