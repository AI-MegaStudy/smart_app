import 'package:flutter/material.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ReturnPage extends StatelessWidget {
  const ReturnPage({super.key});

  void _confirm(BuildContext context, String label, String message) {
    showConfirmAction(
      context: context,
      title: '반품 요청 $label',
      message: '반품 · 환불 상태를 $label 처리할까요?',
      confirmLabel: label,
      onConfirm: () => showOwnerSnack(context, message),
    );
  }

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
          const LabeledField(
            label: '구매 상품 금액',
            value: '39,000원',
            enabled: false,
          ),
          const LabeledField(
            label: '고객 요청 사유',
            value: '배송 중 박스 파손',
            enabled: false,
          ),
          const LabeledField(label: '결정', value: '승인', enabled: false),
          const LabeledField(label: '승인 금액', value: '39,000원', enabled: false),
          const LabeledBox(
            label: '결정 사유',
            value: '박스 외부 파손과 일부 멍이 확인되어 부분 환불합니다.',
            enabled: false,
          ),
          DualActionBar(
            left: '거절',
            right: '환불 승인',
            onLeftPressed: () => _confirm(context, '거절', '반품 요청을 거절했습니다.'),
            onRightPressed: () => _confirm(context, '환불 승인', '환불 승인을 완료했습니다.'),
          ),
        ],
      ),
    );
  }
}
