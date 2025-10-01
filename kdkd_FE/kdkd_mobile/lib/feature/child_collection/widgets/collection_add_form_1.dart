import 'package:flutter/material.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field_with_label.dart';
import 'package:kdkd_mobile/feature/child_collection/pages/child_collection_edit_page.dart';

class CollectionAddForm1 extends StatefulWidget {
  final String initialBoxName;
  final String initialTargetAmount;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPriceChanged;
  final Function(String?) onBankSelected;
  final Function(String?)? onImageSelected;

  const CollectionAddForm1({
    super.key,
    this.initialBoxName = '',
    this.initialTargetAmount = '',
    required this.onNameChanged,
    required this.onPriceChanged,
    required this.onBankSelected,
    this.onImageSelected,
  });

  @override
  State<CollectionAddForm1> createState() => _CollectionAddForm1State();
}

class _CollectionAddForm1State extends State<CollectionAddForm1> {
  // final List<String> _banks = ['KB국민은행', '신한은행', '우리은행', '하나은행']; // 사용하지 않으므로 주석 처리
  // String? _selectedBank; // 사용하지 않으므로 주석 처리
  late TextEditingController _boxNameController;
  late TextEditingController _targetAmountController;

  @override
  void initState() {
    super.initState();
    _boxNameController = TextEditingController(text: widget.initialBoxName);
    _targetAmountController = TextEditingController(text: widget.initialTargetAmount);

    // 초기값 콜백 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialBoxName.isNotEmpty) {
        widget.onNameChanged(widget.initialBoxName);
      }
      if (widget.initialTargetAmount.isNotEmpty) {
        widget.onPriceChanged(widget.initialTargetAmount);
      }
    });
  }

  @override
  void dispose() {
    _boxNameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFieldWithLabel(
            title: "통장이름",
            controller: _boxNameController,
            onChanged: widget.onNameChanged,
          ),
          DottedLineSeparator(),
          CustomTextFieldWithLabel(
            title: "목표금액",
            controller: _targetAmountController,
            onChanged: widget.onPriceChanged,
            keyboardType: TextInputType.number,
            autoFormat: true,
          ),
          DottedLineSeparator(),
          SelectPictureWidget(
            onImageSelected: widget.onImageSelected,
          ),
        ],
      ),
    );
  }
}
