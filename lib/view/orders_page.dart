import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        title: '예약 · 주문 현황',
        subtitle: '오늘 들어온 고객 요청',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: ActionChipIcon(
          icon: Icons.search,
          onPressed: () => showOwnerSnack(context, '주문 검색을 시작합니다.'),
        ),
        children: const [
          ChipRow(labels: ['전체', '예약', '결제 완료', '배송 준비']),
          DataTile(
            icon: Icons.receipt_long_outlined,
            title: '정다은 · 홍로 5kg',
            subtitle: '2박스 · 78,000원 · 10.12 수확분',
            badge: '결제 완료',
            badgeColor: AppColors.blue,
          ),
          DataTile(
            icon: Icons.receipt_long_outlined,
            title: '김민지 · 부사 3kg',
            subtitle: '1박스 · 32,000원 · 10.20 수확분',
            badge: '예약 중',
            badgeColor: AppColors.yellow,
          ),
          DataTile(
            icon: Icons.receipt_long_outlined,
            title: '박서준 · 시나노골드',
            subtitle: '1박스 · 68,000원 · 배송 준비',
            badge: '준비',
            badgeColor: AppColors.mint,
          ),
        ],
      ),
    );
  }
}
