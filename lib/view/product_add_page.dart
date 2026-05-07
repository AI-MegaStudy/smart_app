import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/model/product_record.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductAddPage extends StatefulWidget {
  final ProductRecord? initialProduct;

  const ProductAddPage({super.key, this.initialProduct});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final packageController = TextEditingController();
  final priceController = TextEditingController();
  String status = '준비 중';

  bool get isEdit => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    final product = widget.initialProduct;
    if (product != null) {
      nameController.text = product.name;
      packageController.text = product.packageUnit.replaceAll(
        RegExp(r'\D'),
        '',
      );
      final priceLabel = product.summary.split('원').first;
      priceController.text = priceLabel.replaceAll(RegExp(r'\D'), '');
      status = product.status;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    packageController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 항목을 입력한 뒤 등록하세요.');
      return;
    }
    showConfirmAction(
      context: context,
      title: isEdit ? '상품 수정' : '상품 등록',
      message: isEdit ? '상품 정보를 수정할까요?' : '새 상품을 등록할까요?',
      confirmLabel: isEdit ? '수정' : '등록',
      onConfirm: () {
        final price = int.parse(priceController.text);
        final product = ProductRecord(
          nameController.text.trim(),
          '${packageController.text}kg 박스',
          '${_formatPrice(price)}원 · 신규 등록',
          status,
          _statusColor(status),
        );
        showOwnerSnack(context, isEdit ? '상품 정보를 수정했습니다.' : '상품을 등록했습니다.');
        Navigator.of(context).pop(product);
      },
    );
  }

  String _formatPrice(int price) {
    final text = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  Color _statusColor(String status) {
    return switch (status) {
      '판매 중' => AppColors.mint,
      '준비 중' => AppColors.yellow,
      _ => const Color(0xffFFE1DD),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: isEdit ? '상품 수정' : '상품 추가',
          subtitle: isEdit ? '상품 정보 수정' : '고객에게 보이는 상품 정보',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            LabeledField(
              label: '상품명',
              value: '',
              controller: nameController,
              hintText: '예: 후지 사과',
            ),
            LabeledField(
              label: '포장 단위',
              value: '',
              controller: packageController,
              hintText: '숫자만 입력하세요. 예: 5',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (text) {
                final base = numericValidator(text);
                return base == null ? null : '포장 단위에는 숫자만 입력하세요.';
              },
              suffixText: 'kg 박스',
            ),
            LabeledField(
              label: '기본 판매가',
              value: '',
              controller: priceController,
              hintText: '숫자만 입력하세요. 예: 39000',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (text) {
                final base = numericValidator(text);
                return base == null ? null : '기본 판매가에는 숫자만 입력하세요.';
              },
              suffixText: '원',
            ),
            LabeledDropdown(
              label: '판매 상태',
              value: status,
              items: const ['판매 중', '준비 중', '중지'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => status = value);
                }
              },
            ),
            DualActionBar(
              left: '취소',
              right: isEdit ? '수정' : '등록',
              onLeftPressed: () => Navigator.of(context).pop(),
              onRightPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
