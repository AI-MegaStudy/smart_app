import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String filter = '전체';

  final orders = const [
    _Order(
      '정다은 · 홍로 5kg',
      '2박스 · 78,000원 · 10.12 수확분',
      '결제 완료',
      AppColors.blue,
    ),
    _Order('김민지 · 부사 3kg', '1박스 · 32,000원 · 10.20 수확분', '예약', AppColors.yellow),
    _Order('박서준 · 시나노골드', '1박스 · 68,000원 · 배송 준비', '배송 준비', AppColors.mint),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = filter == '전체'
        ? orders
        : orders.where((order) => order.status == filter).toList();

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
        children: [
          FilterTabs(
            labels: const ['전체', '예약', '결제 완료', '배송 준비'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          for (final order in visible)
            DataTile(
              icon: Icons.receipt_long_outlined,
              title: order.title,
              subtitle: order.subtitle,
              badge: order.status,
              badgeColor: order.color,
            ),
        ],
      ),
    );
  }
}

class _Order {
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const _Order(this.title, this.subtitle, this.status, this.color);
}
