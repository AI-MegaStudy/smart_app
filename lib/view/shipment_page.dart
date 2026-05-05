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
  final invoiceController = TextEditingController(text: '5891-1202-4810');
  String courier = 'CJ대한통운';
  String boxes = '2박스';
  String weight = '10kg';

  @override
  void dispose() {
    invoiceController.dispose();
    super.dispose();
  }

  void _registerShipment() {
    showConfirmAction(
      context: context,
      title: '배송 등록',
      message: '$courier, $boxes, $weight 기준으로 배송 상태를 갱신할까요?',
      confirmLabel: '등록',
      onConfirm: () =>
          showOwnerSnack(context, '$courier $boxes $weight 배송 정보가 등록되었습니다.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
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
          const DataTile(
            icon: Icons.local_shipping_outlined,
            title: '정다은 · 홍로 5kg',
            subtitle: '2박스 · 선별 완료 · 포장 대기',
            badge: '준비',
            badgeColor: AppColors.mint,
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
            label: '송장 번호',
            value: '',
            controller: invoiceController,
            hintText: '송장 번호를 입력하세요.',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              const DashTextInputFormatter([4, 4, 4]),
            ],
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
    );
  }
}
