import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProcurementPage extends StatelessWidget {
  const ProcurementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: '발주 승인',
        subtitle: '결제 후 생성된 처리 요청',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        children: [
          const ChipRow(labels: ['승인 대기', '승인 완료', '거절']),
          const DataTile(
            icon: Icons.inventory_2_outlined,
            title: '발주 2026-1012-04',
            subtitle: '홍길동 · 후지 5kg 2박스 · 오늘 14:02',
            badge: '대기',
            badgeColor: AppColors.yellow,
          ),
          const DataTile(
            icon: Icons.inventory_2_outlined,
            title: '발주 2026-1012-03',
            subtitle: '이수빈 · 홍로 3kg 1박스 · 오늘 13:18',
            badge: '대기',
            badgeColor: AppColors.yellow,
          ),
          const LabeledField(label: '승인 박스 수', value: '2박스'),
          const LabeledField(label: '승인 수량', value: '10kg'),
          DualActionBar(
            left: '부분 승인',
            right: '승인',
            onLeftPressed: () =>
                showOwnerSnack(context, '부분 승인으로 발주 결정을 저장했습니다.'),
            onRightPressed: () => showOwnerSnack(context, '발주를 승인했습니다.'),
          ),
        ],
      ),
    );
  }
}
