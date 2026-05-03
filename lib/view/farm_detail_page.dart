import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class FarmDetailPage extends StatelessWidget {
  const FarmDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: '농장 정보 수정',
        subtitle: '고객에게 보이는 농장 기본 정보',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        children: [
          const HeroPanel(
            eyebrow: '충북 충주',
            title: '햇살농원',
            icon: Icons.local_florist,
            compact: true,
          ),
          const NoticeBox(
            color: AppColors.yellow,
            text: '농장 기본 정보는 고객 상품 상세와 예약 화면에 노출됩니다.',
          ),
          const LabeledField(label: '농장명', value: '충주 햇살농원'),
          const LabeledField(label: '지역', value: '충북 충주'),
          const LabeledField(label: '주소', value: '충북 충주시 산척면 과수원길 24'),
          const LabeledBox(label: '소개', value: '당도 선별 사과를 수확 일정에 맞춰 직배송합니다.'),
          const LabeledBox(
            label: '배송 정책',
            value: '수확 후 24시간 안에 포장하고 산지에서 바로 발송합니다.',
          ),
          const LabeledBox(
            label: '반품 정책',
            value: '배송 중 파손 또는 품질 이상 확인 시 사진 확인 후 환불을 처리합니다.',
          ),
          PrimaryAction(
            label: '저장',
            onPressed: () => showOwnerSnack(context, '농장 정보가 저장되었습니다.'),
          ),
        ],
      ),
    );
  }
}
