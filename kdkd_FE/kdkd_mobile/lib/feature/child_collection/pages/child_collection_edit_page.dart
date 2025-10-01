import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/modal/custom_bottom_modal.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field_with_label.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/child_collection/models/collection_model.dart';
import 'package:kdkd_mobile/feature/child_collection/models/create_collection_request.dart';
import 'package:kdkd_mobile/feature/child_collection/providers/collection_provider.dart';
import 'package:kdkd_mobile/feature/child_collection/repositories/collection_api.dart';

class ChildCollectionEditPage extends ConsumerStatefulWidget {
  final CollectionModel collection;

  const ChildCollectionEditPage({
    super.key,
    required this.collection,
  });

  @override
  ConsumerState<ChildCollectionEditPage> createState() =>
      _ChildCollectionEditPageState();
}

class _ChildCollectionEditPageState
    extends ConsumerState<ChildCollectionEditPage> {
  late TextEditingController _boxNameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _savingAmountController;
  String? _imageFilePath;

  @override
  void initState() {
    super.initState();
    _boxNameController = TextEditingController(text: widget.collection.boxName);
    _targetAmountController =
        TextEditingController(text: widget.collection.target.toString());
    _savingAmountController = TextEditingController(
        text: (widget.collection.target - widget.collection.remain).toString());
  }

  @override
  void dispose() {
    _boxNameController.dispose();
    _targetAmountController.dispose();
    _savingAmountController.dispose();
    super.dispose();
  }

  void _showUpdateConfirmModal() {
    CustomBottomModal.show(
      context: context,
      confirmText: '수정하기',
      onConfirm: () async {
        Navigator.pop(context);
        await _updateCollection();
      },
      child: UpdateConfirmModal(
        boxName: _boxNameController.text,
        targetAmount: _parseAmount(_targetAmountController.text),
        savingAmount: _parseAmount(_savingAmountController.text),
      ),
    );
  }

  Future<void> _updateCollection() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모으기 상자를 수정중입니다...')),
      );

      final request = CreateCollectionRequest(
        boxName: _boxNameController.text.trim(),
        saving: _parseAmount(_savingAmountController.text),
        target: _parseAmount(_targetAmountController.text),
      );

      final api = ref.read(collectionApiProvider);
      await api.updateCollection(
        boxUuid: widget.collection.boxUuid,
        request: request,
        imageFilePath: _imageFilePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${_boxNameController.text} 모으기 상자가 수정되었습니다!')),
        );

        // 목록 새로고침
        ref.read(collectionProvider.notifier).fetchCollections();

        // 이전 페이지로 이동
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: ${e.toString()}')),
        );
      }
    }
  }

  int _parseAmount(String amount) {
    if (amount.trim().isEmpty) return 0;
    return int.tryParse(amount.replaceAll(',', '').replaceAll('원', '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '모으기 수정',
        useBackspace: true,
        actionType: AppBarActionType.none,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            CustomTextFieldWithLabel(
              title: "통장이름",
              controller: _boxNameController,
            ),
            const DottedLineSeparator(),
            CustomTextFieldWithLabel(
              title: "목표금액",
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              autoFormat: true,
            ),
            const DottedLineSeparator(),
            CustomTextFieldWithLabel(
              title: "현재 저금액",
              controller: _savingAmountController,
              keyboardType: TextInputType.number,
              autoFormat: true,
            ),
            const DottedLineSeparator(),
            SelectPictureWidget(
              initialImageUrl: widget.collection.imageUrl,
              onImageSelected: (imagePath) {
                setState(() {
                  _imageFilePath = imagePath;
                });
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showUpdateConfirmModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '수정하기',
                  style: AppFonts.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateConfirmModal extends StatelessWidget {
  final String boxName;
  final int targetAmount;
  final int savingAmount;

  const UpdateConfirmModal({
    super.key,
    required this.boxName,
    required this.targetAmount,
    required this.savingAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '수정 내용을 확인해주세요',
            style: AppFonts.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('통장이름', boxName),
          const SizedBox(height: 12),
          _buildInfoRow('목표금액', '${targetAmount.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match match) => '${match[1]},',
              )}원'),
          const SizedBox(height: 12),
          _buildInfoRow('현재 저금액', '${savingAmount.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match match) => '${match[1]},',
              )}원'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.grayMedium,
          ),
        ),
        Text(
          value,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DottedLineSeparator extends StatelessWidget {
  const DottedLineSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: CustomPaint(
        painter: DottedLinePainter(),
        size: const Size(double.infinity, 1),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grayLight
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SelectPictureWidget extends StatefulWidget {
  final Function(String?)? onImageSelected;
  final String? initialImageUrl;

  const SelectPictureWidget({
    super.key,
    this.onImageSelected,
    this.initialImageUrl,
  });

  @override
  State<SelectPictureWidget> createState() => _SelectPictureWidgetState();
}

class _SelectPictureWidgetState extends State<SelectPictureWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        widget.onImageSelected?.call(image.path);
      }
    } catch (e) {
      print('이미지 선택 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Widget _buildImageDisplay() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _selectedImage!,
          width: double.infinity,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.initialImageUrl!,
          width: double.infinity,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 32,
            color: AppColors.grayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '사진을 추가해보세요',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.grayMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진 선택',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickImage,
          child: _buildImageDisplay(),
        ),
        if (_selectedImage != null || widget.initialImageUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('변경'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                    widget.onImageSelected?.call(null);
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('삭제'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}