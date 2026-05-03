import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class HarvestSlotPage extends StatelessWidget {
  const HarvestSlotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: '수확 예측 · 슬롯 확정',
        subtitle: '후지 사과 5kg',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: ActionChipIcon(
          icon: Icons.refresh,
          onPressed: () => showOwnerSnack(context, '수확 예측을 새로고침했습니다.'),
        ),
        children: [
          const NoticeBox(
            color: AppColors.blue,
            text: '예측은 참고 자료입니다. 실제 예약 오픈 수량은 점주가 확정합니다.',
          ),
          const YieldChart(),
          const GridCards(
            children: [
              MetricCard(
                icon: Icons.calendar_month_outlined,
                value: '10.12-10.18',
                label: '예상 수확 범위',
              ),
              MetricCard(
                icon: Icons.scale_outlined,
                value: '420kg',
                label: '예상 수확량',
              ),
              MetricCard(
                icon: Icons.shopping_bag_outlined,
                value: '260-320kg',
                label: '권장 예약량',
              ),
              MetricCard(
                icon: Icons.paid_outlined,
                value: '39,000원',
                label: '권장 판매가',
              ),
            ],
          ),
          const NoticeBox(
            color: AppColors.yellow,
            text: '고객에게 보이는 수확 기간, 예약 가능 수량, 판매가는 이 화면에서 확정한 값입니다.',
          ),
          const LabeledField(label: '예약 오픈 수량', value: '300kg'),
          const LabeledBox(
            label: '고객 안내 문구',
            value: '수확 예정 범위는 기상과 생육 상황에 따라 조정될 수 있습니다.',
          ),
          DualActionBar(
            left: '임시 저장',
            right: '예약 오픈',
            onLeftPressed: () =>
                showOwnerSnack(context, '수확 슬롯 초안을 임시 저장했습니다.'),
            onRightPressed: () => showOwnerSnack(context, '예약 오픈 상태로 전환했습니다.'),
          ),
        ],
      ),
    );
  }
}
