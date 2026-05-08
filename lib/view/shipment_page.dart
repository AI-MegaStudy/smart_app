import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/procurement_status_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ShipmentPage extends StatefulWidget {
  const ShipmentPage({super.key});

  @override
  State<ShipmentPage> createState() => _ShipmentPageState();
}

class _ShipmentPageState extends State<ShipmentPage> {
  final formKey = GlobalKey<FormState>();
  final invoiceController = TextEditingController();
  String selectedProduct = '';
  String courier = '';
  String boxes = '';
  String weight = '';

  @override
  void dispose() {
    invoiceController.dispose();
    super.dispose();
  }

  void _selectProduct(String value) {
    final product = _ShipmentProduct.approvedItems.firstWhere(
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
                for (final product in _ShipmentProduct.approvedItems)
                  product.name,
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
              hintText: '송장번호',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                const DashTextInputFormatter([4, 4, 4]),
              ],
              regexHint: '1234-1234-1234',
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

  static List<_ShipmentProduct> get approvedItems {
    final approved = procurementStatusRecords.where(
      (record) => record.status == '승인 완료',
    );
    return [
      for (final record in approved)
        _ShipmentProduct(
          record.subtitle.split(' · ').take(2).join(' · '),
          '1박스',
          '5kg',
        ),
    ];
  }
}
