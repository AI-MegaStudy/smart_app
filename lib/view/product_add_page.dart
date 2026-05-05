import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final packageController = TextEditingController();
  final priceController = TextEditingController();
  String status = '준비 중';

  @override
  void dispose() {
    nameController.dispose();
    packageController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 항목을 입력한 뒤 저장하세요.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '상품 저장',
      message: '새 상품을 추가할까요?',
      confirmLabel: '저장',
      onConfirm: () {
        showOwnerSnack(context, '상품이 추가되었습니다.');
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '상품 추가',
          subtitle: '판매 상품 기본 정보',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            LabeledField(
              label: '상품명',
              value: '',
              controller: nameController,
              hintText: '예: 홍로 사과 5kg',
            ),
            LabeledField(
              label: '포장 단위',
              value: '',
              controller: packageController,
              hintText: '예: 5kg 박스',
            ),
            LabeledField(
              label: '기본 판매가',
              value: '',
              controller: priceController,
              hintText: '숫자만 입력하세요. 예: 39000',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              right: '저장',
              onLeftPressed: () => Navigator.of(context).pop(),
              onRightPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
