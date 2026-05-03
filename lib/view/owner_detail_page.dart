import 'package:flutter/material.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class OwnerDetailPage extends StatelessWidget {
  const OwnerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: '내 정보 수정',
        subtitle: '점주 기본 정보',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        children: [
          const LabeledField(label: '이름', value: '김하늘'),
          const LabeledField(label: '전화번호', value: '010-2222-3344'),
          const LabeledField(label: '사업자번호', value: '312-45-67890'),
          const LabeledField(label: '알림', value: '발주와 반품 요청 즉시 알림'),
          PrimaryAction(
            label: '저장',
            onPressed: () => showOwnerSnack(context, '내 정보가 저장되었습니다.'),
          ),
        ],
      ),
    );
  }
}
