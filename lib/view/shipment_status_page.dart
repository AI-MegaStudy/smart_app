import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ShipmentStatusPage extends StatefulWidget {
  const ShipmentStatusPage({super.key});

  @override
  State<ShipmentStatusPage> createState() => _ShipmentStatusPageState();
}

class _ShipmentStatusPageState extends State<ShipmentStatusPage> {
  final searchController = TextEditingController();
  String filter = '전체';
  bool showSearch = false;

  final shipments = const [
    _Shipment(
      '홍길동 · 양광 5kg',
      'CJ대한통운 · 5891-1202-4810 · 2026-05-07 09:50',
      '배송 중',
      AppColors.mint,
    ),
    _Shipment(
      '김민지 · 부사 3kg',
      '송장 입력 대기 · 2026-05-07 10:20',
      '대기',
      AppColors.yellow,
    ),
    _Shipment(
      '박서준 · 양광 7kg',
      '롯데택배 · 1234-1234-1234 · 2026-05-07 11:30',
      '배송 완료',
      AppColors.blue,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final visible = shipments.where((item) {
      final matchesFilter = filter == '전체' || item.status == filter;
      final matchesQuery =
          query.isEmpty ||
          '${item.title} ${item.subtitle} ${item.status}'
              .toLowerCase()
              .contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      body: AppScaffold(
        title: '배송 현황',
        subtitle: '송장과 발송 상태',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: ActionChipIcon(
          icon: showSearch ? Icons.close : Icons.search,
          onPressed: () {
            setState(() {
              showSearch = !showSearch;
              if (!showSearch) {
                searchController.clear();
              }
            });
          },
        ),
        children: [
          if (showSearch)
            TextField(
              controller: searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '배송 상품, 송장번호, 상태를 검색하세요',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          FilterTabs(
            labels: const ['전체', '대기', '배송 중', '배송 완료'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          for (final item in visible)
            DataTile(
              icon: Icons.local_shipping_outlined,
              title: item.title,
              subtitle: item.subtitle,
              badge: item.status,
              badgeColor: item.color,
            ),
        ],
      ),
    );
  }
}

class _Shipment {
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const _Shipment(this.title, this.subtitle, this.status, this.color);
}
