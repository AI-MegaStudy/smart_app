import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class HarvestSlotPage extends StatefulWidget {
  const HarvestSlotPage({super.key});

  @override
  State<HarvestSlotPage> createState() => _HarvestSlotPageState();
}

class _HarvestSlotPageState extends State<HarvestSlotPage> {
  final formKey = GlobalKey<FormState>();
  final openQuantityController = TextEditingController();
  final guideController = TextEditingController();

  @override
  void dispose() {
    openQuantityController.dispose();
    guideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '수확 예측 · 슬롯 확정',
          subtitle: '양광 사과 5kg',
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
            LabeledNumberField(
              label: '예약 오픈 수량',
              value: '',
              controller: openQuantityController,
              suffixText: 'kg',
              hintText: '예약 오픈 수량',
              validator: (text) {
                final base = numericValidator(text);
                return base == null ? null : '예약 오픈 수량에는 숫자만 입력하세요.';
              },
            ),
            LabeledBox(
              label: '고객 안내 문구',
              value: '',
              controller: guideController,
            ),
            DualActionBar(
              left: '취소',
              right: '예약 오픈',
              onLeftPressed: () => Navigator.of(context).pop(),
              onRightPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  showOwnerSnack(context, '모든 항목을 입력해야 예약 오픈이 가능합니다.');
                  return;
                }
                showConfirmAction(
                  context: context,
                  title: '예약 오픈',
                  message: '고객에게 예약 슬롯을 오픈할까요?',
                  confirmLabel: '예약 오픈',
                  onConfirm: () => showOwnerSnack(context, '예약 오픈 상태로 전환했습니다.'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
