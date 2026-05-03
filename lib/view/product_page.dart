import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: '상품 관리',
        subtitle: '포장 단위와 가격 관리',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: ActionChipIcon(
          icon: Icons.add,
          onPressed: () => showOwnerSnack(context, '새 상품 입력 영역으로 이동합니다.'),
        ),
        children: [
          const ChipRow(labels: ['판매 중', '준비 중', '중지']),
          const DataTile(
            icon: Icons.local_florist,
            title: '홍로 사과 5kg',
            subtitle: '39,000원 · 수확 슬롯 2개',
            badge: '판매 중',
            badgeColor: AppColors.mint,
          ),
          const DataTile(
            icon: Icons.local_florist,
            title: '부사 사과 3kg',
            subtitle: '32,000원 · 잔여 42kg',
            badge: '확인',
            badgeColor: AppColors.yellow,
          ),
          const SectionHeader(title: '상품 빠른 등록'),
          const LabeledField(label: '상품명', value: '시나노골드 사과'),
          const LabeledField(label: '포장 단위', value: '7.5kg 박스'),
          const LabeledField(label: '기본 판매가', value: '68,000원'),
          PrimaryAction(
            label: '상품 저장',
            onPressed: () => showOwnerSnack(context, '상품 정보가 저장되었습니다.'),
          ),
        ],
      ),
    );
  }
}
