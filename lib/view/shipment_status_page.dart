import 'package:flutter/material.dart';
import 'package:smart_app/repositories/shipment_repository.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ShipmentStatusPage extends StatefulWidget {
  const ShipmentStatusPage({super.key});

  @override
  State<ShipmentStatusPage> createState() => _ShipmentStatusPageState();
}

class _ShipmentStatusPageState extends State<ShipmentStatusPage> {
  final repository = ShipmentRepository();
  final searchController = TextEditingController();
  String filter = '전체';
  bool showSearch = false;
  bool isWorking = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _markDelivered(ShipmentRecord item) async {
    final shipmentId = item.shipmentId;
    if (shipmentId == null) {
      showOwnerSnack(context, '서버 shipment_id가 없어 상태를 변경할 수 없습니다.');
      return;
    }
    if (item.status == '배송 완료') {
      showOwnerSnack(context, '이미 배송 완료 상태입니다.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('배송 완료 처리'),
        content: Text('${item.title} 배송을 완료 처리할까요?'),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('완료 처리'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => isWorking = true);
    try {
      final updated = await repository.updateStatus(
        shipmentId: shipmentId,
        shipmentStatus: 'DELIVERED',
      );
      if (!mounted) return;
      final index = shipmentStatusRecords.indexOf(item);
      if (index >= 0) {
        shipmentStatusRecords[index] = item.copyWith(
          status: updated.statusLabel,
          color: updated.color,
        );
      }
      setState(() {});
      showOwnerSnack(context, '배송 완료로 변경했습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final visible = shipmentStatusRecords.where((item) {
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
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: ActionChipIcon(
          icon: showSearch ? Icons.close : Icons.search,
          onPressed: () {
            setState(() {
              showSearch = !showSearch;
              if (!showSearch) searchController.clear();
            });
          },
        ),
        children: [
          if (isWorking) const LinearProgressIndicator(),
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
            labels: const ['전체', '배송 대기', '배송 중', '배송 완료'],
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
              onTap: () => _markDelivered(item),
              showChevron: item.shipmentId != null,
            ),
          if (!isWorking && visible.isEmpty)
            const NoticeBox(
              color: Color(0xffFFF4CC),
              text:
                  '등록된 배송 현황이 없습니다. 현재 최종 백엔드 명세에는 점주용 배송 목록 조회 API가 없어 앱에서 방금 등록한 배송만 표시할 수 있습니다.',
            ),
        ],
      ),
    );
  }
}

final shipmentStatusRecords = <ShipmentRecord>[];

class ShipmentRecord {
  final String title;
  final String subtitle;
  final String status;
  final Color color;
  final int? shipmentId;

  const ShipmentRecord(
    this.title,
    this.subtitle,
    this.status,
    this.color, {
    this.shipmentId,
  });

  ShipmentRecord copyWith({
    String? status,
    Color? color,
  }) {
    return ShipmentRecord(
      title,
      subtitle,
      status ?? this.status,
      color ?? this.color,
      shipmentId: shipmentId,
    );
  }
}
