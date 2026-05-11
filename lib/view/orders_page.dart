import 'package:flutter/material.dart';
import 'package:smart_app/model/owner_order_record.dart';
import 'package:smart_app/repositories/order_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final repository = OrderRepository();
  final searchController = TextEditingController();

  String filter = '전체';
  bool showSearch = false;
  bool isLoading = false;
  String? errorMessage;
  List<OwnerOrderRecord> records = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final nextRecords = await repository.fetchOwnerOrderStatus();
      if (!mounted) return;
      setState(() => records = nextRecords);
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final visible = records.where((record) {
      final matchesFilter = filter == '전체' || record.statusLabel == filter;
      final matchesQuery =
          query.isEmpty ||
          '${record.title} ${record.subtitle} ${record.statusLabel}'
              .toLowerCase()
              .contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      body: AppScaffold(
        title: '주문 현황',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionChipIcon(
              icon: Icons.refresh,
              onPressed: isLoading ? null : _load,
            ),
            const SizedBox(width: 6),
            ActionChipIcon(
              icon: showSearch ? Icons.close : Icons.search,
              onPressed: () {
                setState(() {
                  showSearch = !showSearch;
                  if (!showSearch) searchController.clear();
                });
              },
            ),
          ],
        ),
        children: [
          if (showSearch)
            TextField(
              controller: searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '고객명, 상품명, 상태를 검색하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
          FilterTabs(
            labels: const ['전체', '예약 완료', '결제 완료', '배송 준비', '배송 완료'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          for (final record in visible)
            DataTile(
              icon: record.source == 'reservation'
                  ? Icons.event_available_outlined
                  : Icons.receipt_long_outlined,
              title: record.title,
              subtitle: record.subtitle,
              badge: record.statusLabel,
              badgeColor: record.color,
            ),
          if (!isLoading && visible.isEmpty)
            const NoticeBox(color: AppColors.yellow, text: '검색 결과가 없습니다.'),
        ],
      ),
    );
  }
}
