import 'package:flutter/material.dart';
import 'package:smart_app/model/return_record.dart';
import 'package:smart_app/repositories/return_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ReturnStatusPage extends StatefulWidget {
  const ReturnStatusPage({super.key});

  @override
  State<ReturnStatusPage> createState() => _ReturnStatusPageState();
}

class _ReturnStatusPageState extends State<ReturnStatusPage> {
  final repository = ReturnRepository();
  final searchController = TextEditingController();
  String filter = '전체';
  bool showSearch = false;
  bool isLoading = false;
  String? errorMessage;
  List<ReturnStatusRecord> records = [];

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
      final returns = await repository.fetchReturns();
      final processed = returns
          .where((item) => !item.canDecide)
          .map(ReturnStatusRecord.fromReturn)
          .toList();
      if (!mounted) return;
      setState(() => records = _mergeRecords(returnStatusRecords, processed));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.toString();
        records = returnStatusRecords.toList();
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final visible = records.where((item) {
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
        title: '반품 · 환불 현황',
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
              decoration: const InputDecoration(
                hintText: '반품 사유, 상품명, 상태를 검색하세요',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
          FilterTabs(
            labels: const ['전체', '승인', '거절'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          for (final item in visible)
            DataTile(
              icon: Icons.assignment_return_outlined,
              title: item.title,
              subtitle: item.subtitle,
              badge: item.status,
              badgeColor: item.color,
              iconBackground: AppColors.mint,
              iconColor: AppColors.green,
            ),
          if (!isLoading && visible.isEmpty)
            const NoticeBox(
              color: AppColors.yellow,
              text: '처리된 반품 · 환불 현황이 없습니다.',
            ),
        ],
      ),
    );
  }
}

final returnStatusRecords = <ReturnStatusRecord>[];

class ReturnStatusRecord {
  final int? returnRequestId;
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const ReturnStatusRecord(
    this.title,
    this.subtitle,
    this.status,
    this.color, {
    this.returnRequestId,
  });

  factory ReturnStatusRecord.fromReturn(ReturnRequestRecord record) {
    return ReturnStatusRecord(
      record.requestedAt,
      '${record.customerName} · ${record.productName} · ${record.approvedAmount}원',
      switch (record.returnStatus) {
        'APPROVED' || 'REFUNDED' => '승인',
        'REJECTED' => '거절',
        _ => record.statusLabel,
      },
      record.color,
      returnRequestId: record.returnRequestId,
    );
  }
}

List<ReturnStatusRecord> _mergeRecords(
  List<ReturnStatusRecord> local,
  List<ReturnStatusRecord> remote,
) {
  final merged = <ReturnStatusRecord>[];
  final seenIds = <int>{};
  for (final item in [...local, ...remote]) {
    final id = item.returnRequestId;
    if (id != null && !seenIds.add(id)) continue;
    merged.add(item);
  }
  return merged;
}
