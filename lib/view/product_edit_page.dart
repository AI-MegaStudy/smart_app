import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/model/product_record.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductEditPage extends StatefulWidget {
  final ProductRecord product;

  const ProductEditPage({super.key, required this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final formKey = GlobalKey<FormState>();
  final packageController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  late String productName;
  late String status;

  @override
  void initState() {
    super.initState();
    productName = widget.product.name;
    packageController.text = widget.product.packageUnit.replaceAll(
      RegExp(r'\D'),
      '',
    );
    priceController.text = widget.product.price.toString();
    stockController.text = widget.product.stockKg.toString();
    status = widget.product.status;
  }

  @override
  void dispose() {
    packageController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 항목을 입력한 뒤 수정하세요.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '상품 수정',
      message: '상품 정보를 수정할까요?',
      confirmLabel: '수정',
      onConfirm: () {
        final product = ProductRecord(
          productName,
          '${packageController.text}kg 박스',
          int.parse(priceController.text),
          int.parse(stockController.text),
          status,
          _statusColor(status),
        );
        showOwnerSnack(context, '상품 정보를 수정했습니다.');
        Navigator.of(context).pop(product);
      },
    );
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
          title: '상품 수정',
          subtitle: '상품 정보 수정',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            LabeledDropdown(
              label: '상품명',
              value: productName,
              items: const ['양광 사과', '부사 사과'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => productName = value);
                }
              },
            ),
            LabeledField(
              label: '포장 단위',
              value: '',
              controller: packageController,
              hintText: '포장 단위',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              regexHint: '숫자만 입력',
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
              hintText: '기본 판매가',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              regexHint: '숫자만 입력',
              validator: (text) {
                final base = numericValidator(text);
                return base == null ? null : '기본 판매가에는 숫자만 입력하세요.';
              },
              suffixText: '원',
            ),
            LabeledField(
              label: '상품 수량',
              value: '',
              controller: stockController,
              hintText: '상품 수량',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              regexHint: '숫자만 입력',
              validator: (text) {
                final base = numericValidator(text);
                return base == null ? null : '상품 수량에는 숫자만 입력하세요.';
              },
              suffixText: 'kg',
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
              right: '수정',
              onLeftPressed: () => Navigator.of(context).pop(),
              onRightPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
