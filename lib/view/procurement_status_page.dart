import 'package:flutter/material.dart';
import 'package:smart_app/model/procurement_record.dart';
import 'package:smart_app/repositories/procurement_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProcurementStatusPage extends StatefulWidget {
  const ProcurementStatusPage({super.key});

  @override
  State<ProcurementStatusPage> createState() => _ProcurementStatusPageState();
}

class _ProcurementStatusPageState extends State<ProcurementStatusPage> {
  final repository = ProcurementRepository();
  final searchController = TextEditingController();
  String filter = '전체';
  bool showSearch = false;
  bool isLoading = false;
  String? errorMessage;
  List<ProcurementStatusRecord> records = [];

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
      final procurements = await repository.fetchProcurements();
      final processed = procurements
          .where((item) => !item.canDecide)
          .map(ProcurementStatusRecord.fromProcurement)
          .toList();
      if (!mounted) return;
      setState(() => records = _mergeRecords(procurementStatusRecords, processed));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.toString();
        records = procurementStatusRecords.toList();
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
        title: '발주 현황',
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
                hintText: '발주 상품, 고객명, 상태를 검색하세요',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
          FilterTabs(
            labels: const ['전체', '승인', '부분 승인', '거절'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          for (final item in visible)
            DataTile(
              icon: Icons.inventory_2_outlined,
              title: item.title,
              subtitle: item.subtitle,
              badge: item.status,
              badgeColor: item.color,
            ),
          if (!isLoading && visible.isEmpty)
            const NoticeBox(
              color: AppColors.yellow,
              text: '처리된 발주 현황이 없습니다.',
            ),
        ],
      ),
    );
  }
}

final procurementStatusRecords = <ProcurementStatusRecord>[];

class ProcurementStatusRecord {
  final int? procurementId;
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const ProcurementStatusRecord(
    this.title,
    this.subtitle,
    this.status,
    this.color, {
    this.procurementId,
  });

  factory ProcurementStatusRecord.fromProcurement(ProcurementRecord record) {
    return ProcurementStatusRecord(
      record.requestedAt,
      record.subtitle,
      switch (record.statusCode) {
        'APPROVED' => '승인',
        'PARTIAL_APPROVED' => '부분 승인',
        'REJECTED' => '거절',
        _ => record.statusLabel,
      },
      record.color,
      procurementId: record.procurementId,
    );
  }
}

List<ProcurementStatusRecord> _mergeRecords(
  List<ProcurementStatusRecord> local,
  List<ProcurementStatusRecord> remote,
) {
  final merged = <ProcurementStatusRecord>[];
  final seenIds = <int>{};
  for (final item in [...local, ...remote]) {
    final id = item.procurementId;
    if (id != null && !seenIds.add(id)) continue;
    merged.add(item);
  }
  return merged;
}
