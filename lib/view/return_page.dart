import 'package:flutter/material.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ReturnPage extends StatelessWidget {
  const ReturnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: '반품 · 환불 관리',
        subtitle: '고객 요청 확인과 결정',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        children: [
          const DataTile(
            icon: Icons.keyboard_return,
            title: '배송 중 파손',
            subtitle: '후지 사과 5kg · 사진 2장 첨부',
            badge: '확인 필요',
            badgeColor: Color(0xffFFE1DD),
          ),
          const LabeledField(label: '결정', value: '승인'),
          const LabeledField(label: '승인 금액', value: '39,000원'),
          const LabeledBox(
            label: '결정 사유',
            value: '박스 외부 파손과 일부 멍이 확인되어 부분 환불합니다.',
          ),
          DualActionBar(
            left: '거절',
            right: '환불 승인',
            onLeftPressed: () => showOwnerSnack(context, '반품 요청을 거절했습니다.'),
            onRightPressed: () => showOwnerSnack(context, '환불 승인을 완료했습니다.'),
          ),
        ],
      ),
    );
  }
}
