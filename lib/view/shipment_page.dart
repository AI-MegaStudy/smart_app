import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ShipmentPage extends StatefulWidget {
  const ShipmentPage({super.key});

  @override
  State<ShipmentPage> createState() => _ShipmentPageState();
}

class _ShipmentPageState extends State<ShipmentPage> {
  final formKey = GlobalKey<FormState>();
  final invoiceController = TextEditingController(text: '5891-1202-4810');
  String selectedProduct = _ShipmentProduct.items.first.name;
  String courier = 'CJ대한통운';
  String boxes = _ShipmentProduct.items.first.boxes;
  String weight = _ShipmentProduct.items.first.weight;

  @override
  void dispose() {
    invoiceController.dispose();
    super.dispose();
  }

  void _selectProduct(String value) {
    final product = _ShipmentProduct.items.firstWhere(
      (item) => item.name == value,
    );
    setState(() {
      selectedProduct = product.name;
      boxes = product.boxes;
      weight = product.weight;
    });
  }

  void _registerShipment() {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 정보를 입력해야 배송 등록이 가능합니다.');
      return;
    }

    showConfirmAction(
      context: context,
      title: '배송 등록',
      message: '$selectedProduct, $courier, $boxes, $weight 기준으로 배송 상태를 갱신할까요?',
      confirmLabel: '등록',
      onConfirm: () =>
          showOwnerSnack(context, '$selectedProduct 배송 정보를 등록했습니다.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '배송 관리',
          subtitle: '출고 준비 주문',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          trailing: ActionChipIcon(
            icon: Icons.qr_code_scanner,
            onPressed: () => showOwnerSnack(context, '포장 바코드 스캔을 준비합니다.'),
          ),
          children: [
            const NoticeBox(
              color: AppColors.blue,
              text: '바코드 스캔 또는 직접 선택으로 배송 정보를 입력하세요.',
            ),
            LabeledDropdown(
              label: '발주 승인 상품',
              value: selectedProduct,
              items: [
                for (final product in _ShipmentProduct.items) product.name,
              ],
              onChanged: (value) {
                if (value != null) {
                  _selectProduct(value);
                }
              },
            ),
            LabeledDropdown(
              label: '택배사',
              value: courier,
              items: const ['CJ대한통운', '롯데택배', '한진택배', '우체국택배', '로젠택배'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => courier = value);
                }
              },
            ),
            LabeledField(
              label: '송장번호',
              value: '',
              controller: invoiceController,
              hintText: '송장번호를 입력하세요',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const DashTextInputFormatter([4, 4, 4]),
              ],
              validator: invoiceNumberValidator,
            ),
            LabeledDropdown(
              label: '발송 박스 수',
              value: boxes,
              items: [for (var i = 1; i <= 10; i++) '$i박스'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => boxes = value);
                }
              },
            ),
            LabeledDropdown(
              label: '발송 중량',
              value: weight,
              items: [for (var i = 1; i <= 20; i++) '${i}kg'],
              onChanged: (value) {
                if (value != null) {
                  setState(() => weight = value);
                }
              },
            ),
            PrimaryAction(label: '배송 등록', onPressed: _registerShipment),
          ],
        ),
      ),
    );
  }
}

class _ShipmentProduct {
  final String name;
  final String boxes;
  final String weight;

  const _ShipmentProduct(this.name, this.boxes, this.weight);

  static const items = [
    _ShipmentProduct('홍길동 · 후지 5kg', '2박스', '10kg'),
    _ShipmentProduct('김민지 · 홍로 3kg', '1박스', '3kg'),
    _ShipmentProduct('박서준 · 시나노골드', '1박스', '8kg'),
  ];
}
