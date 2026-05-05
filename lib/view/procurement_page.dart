import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProcurementPage extends StatefulWidget {
  const ProcurementPage({super.key});

  @override
  State<ProcurementPage> createState() => _ProcurementPageState();
}

class _ProcurementPageState extends State<ProcurementPage> {
  String filter = '전체';
  String approvedBoxes = '2박스';
  String approvedWeight = '10kg';

  final procurements = const [
    _Procurement(
      '발주 2026-1012-04',
      '홍길동 · 후지 5kg 2박스 · 오늘 14:02',
      '승인 대기',
      AppColors.yellow,
    ),
    _Procurement(
      '발주 2026-1012-03',
      '이수빈 · 홍로 3kg 1박스 · 오늘 13:18',
      '승인 대기',
      AppColors.yellow,
    ),
    _Procurement(
      '발주 2026-1011-09',
      '박서준 · 부사 3kg 1박스',
      '승인 완료',
      AppColors.mint,
    ),
    _Procurement(
      '발주 2026-1010-02',
      '김민지 · 재고 부족으로 거절',
      '거절',
      Color(0xffFFE1DD),
    ),
  ];

  void _confirmDecision(String label, String message) {
    showConfirmAction(
      context: context,
      title: '발주 $label',
      message: '$approvedBoxes, $approvedWeight 기준으로 발주 상태를 갱신할까요?',
      confirmLabel: label,
      onConfirm: () => showOwnerSnack(context, message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = filter == '전체'
        ? procurements
        : procurements.where((item) => item.status == filter).toList();

    return Scaffold(
      body: AppScaffold(
        title: '발주 승인',
        subtitle: '결제 후 생성된 처리 요청',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        children: [
          FilterTabs(
            labels: const ['전체', '승인 대기', '승인 완료', '거절'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          for (final item in visible)
            DataTile(
              icon: Icons.inventory_2_outlined,
              title: item.title,
              subtitle: item.subtitle,
              badge: item.status,
              badgeColor: item.color,
            ),
          LabeledDropdown(
            label: '승인 박스 수',
            value: approvedBoxes,
            items: [for (var i = 1; i <= 10; i++) '$i박스'],
            onChanged: (value) {
              if (value != null) {
                setState(() => approvedBoxes = value);
              }
            },
          ),
          LabeledDropdown(
            label: '승인 중량',
            value: approvedWeight,
            items: [for (var i = 1; i <= 20; i++) '${i}kg'],
            onChanged: (value) {
              if (value != null) {
                setState(() => approvedWeight = value);
              }
            },
          ),
          DualActionBar(
            left: '부분 승인',
            right: '승인',
            onLeftPressed: () => _confirmDecision(
              '부분 승인',
              '$approvedBoxes, $approvedWeight 부분 승인으로 저장했습니다.',
            ),
            onRightPressed: () => _confirmDecision(
              '승인',
              '$approvedBoxes, $approvedWeight 발주를 승인했습니다.',
            ),
          ),
        ],
      ),
    );
  }
}

class _Procurement {
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const _Procurement(this.title, this.subtitle, this.status, this.color);
}
