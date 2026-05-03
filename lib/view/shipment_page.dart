import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ShipmentPage extends StatelessWidget {
  const ShipmentPage({super.key});

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
          const LabeledField(label: '택배사', value: 'CJ대한통운'),
          const LabeledField(label: '송장 번호', value: '5891-1202-4810'),
          const LabeledField(label: '발송 박스 수', value: '2박스'),
          const LabeledField(label: '발송 중량', value: '10kg'),
          PrimaryAction(
            label: '배송 등록',
            onPressed: () => showOwnerSnack(context, '배송 정보가 등록되었습니다.'),
          ),
        ],
      ),
    );
  }
}
