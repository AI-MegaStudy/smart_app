import 'package:flutter/material.dart';
import 'package:smart_app/model/procurement_record.dart';
import 'package:smart_app/repositories/procurement_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/procurement_status_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProcurementPage extends StatefulWidget {
  const ProcurementPage({super.key});

  @override
  State<ProcurementPage> createState() => _ProcurementPageState();
}

class _ProcurementPageState extends State<ProcurementPage> {
  final repository = ProcurementRepository();
  final searchController = TextEditingController();
  final selectedIds = <int>{};

  bool showSearch = false;
  bool isLoading = false;
  bool isWorking = false;
  String? errorMessage;
  List<ProcurementRecord> requests = [];

  List<ProcurementRecord> get enabledRequests =>
      requests.where((item) => item.canDecide).toList();

  bool get allSelected =>
      enabledRequests.isNotEmpty && selectedIds.length == enabledRequests.length;

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
      final records = await repository.fetchProcurements();
      if (!mounted) return;
      setState(() => requests = records);
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _toggleAll(bool? selected) {
    setState(() {
      selectedIds
        ..clear()
        ..addAll(
          selected == true
              ? enabledRequests.map((item) => item.procurementId)
              : const <int>[],
        );
    });
  }

  void _confirmApprove() {
    if (selectedIds.isEmpty) {
      showOwnerSnack(context, '처리할 발주를 선택하세요.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '발주 승인',
      message: '선택한 ${selectedIds.length}건을 승인 처리할까요?',
      confirmLabel: '승인',
      onConfirm: _approveSelected,
    );
  }

  Future<void> _confirmReject() async {
    if (selectedIds.isEmpty) {
      showOwnerSnack(context, '처리할 발주를 선택하세요.');
      return;
    }
    var reason = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('발주 거절'),
              content: DropdownButtonFormField<String>(
                initialValue: reason,
                items: const [
                  DropdownMenuItem(value: '', child: Text('선택하세요')),
                  DropdownMenuItem(value: '재고 부족', child: Text('재고 부족')),
                  DropdownMenuItem(value: '품질 기준 미달', child: Text('품질 기준 미달')),
                  DropdownMenuItem(value: '출고 일정 불가', child: Text('출고 일정 불가')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => reason = value);
                  }
                },
                decoration: const InputDecoration(labelText: '거절 사유'),
              ),
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
                        onPressed: reason.isEmpty
                            ? null
                            : () => Navigator.of(context).pop(true),
                        child: const Text('거절'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed == true) {
      await _rejectSelected(reason);
    }
  }

  Future<void> _approveSelected() async {
    await _applyDecision(
      action: (record) => repository.approve(record),
      statusLabel: '승인',
      color: AppColors.mint,
    );
  }

  Future<void> _rejectSelected(String reason) async {
    await _applyDecision(
      action: (record) => repository.reject(procurement: record, reason: reason),
      statusLabel: '거절',
      color: const Color(0xffFFE1DD),
      reason: reason,
    );
  }

  Future<void> _applyDecision({
    required Future<ProcurementRecord> Function(ProcurementRecord) action,
    required String statusLabel,
    required Color color,
    String? reason,
  }) async {
    final selected = requests
        .where((item) => selectedIds.contains(item.procurementId))
        .toList(growable: false);
    setState(() => isWorking = true);
    try {
      final updated = <ProcurementRecord>[];
      for (final record in selected) {
        updated.add(await action(record));
      }
      if (!mounted) return;
      setState(() {
        for (final record in updated) {
          final index = requests.indexWhere(
            (item) => item.procurementId == record.procurementId,
          );
          if (index >= 0) requests[index] = record;
          procurementStatusRecords.insert(
            0,
            ProcurementStatusRecord(
              record.requestedAt,
              reason == null ? record.subtitle : '${record.subtitle} · $reason',
              statusLabel,
              color,
              procurementId: record.procurementId,
            ),
          );
        }
        selectedIds.clear();
      });
      showOwnerSnack(context, '발주 현황을 갱신했습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) {
        setState(() => isWorking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final visible = requests.where((request) {
      return query.isEmpty ||
          '${request.title} ${request.subtitle} ${request.statusLabel}'
              .toLowerCase()
              .contains(query);
    }).toList();

    return Scaffold(
      body: AppScaffold(
        title: '발주 승인',
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
                hintText: '고객명, 상품명, 상태를 검색하세요',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
          for (final request in visible)
            _ApprovalTile(
              request: request,
              selected: selectedIds.contains(request.procurementId),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    selectedIds.add(request.procurementId);
                  } else {
                    selectedIds.remove(request.procurementId);
                  }
                });
              },
            ),
          if (!isLoading && visible.isEmpty)
            const NoticeBox(color: AppColors.yellow, text: '발주 요청이 없습니다.'),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _toggleAll(!allSelected),
              child: Text(allSelected ? '전체 선택 해제' : '전체 선택'),
            ),
          ),
          DualActionBar(
            left: isWorking ? '처리 중' : '거절',
            right: isWorking ? '처리 중' : '승인',
            onLeftPressed: isWorking ? null : _confirmReject,
            onRightPressed: isWorking ? null : _confirmApprove,
          ),
        ],
      ),
    );
  }
}

class _ApprovalTile extends StatelessWidget {
  final ProcurementRecord request;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  const _ApprovalTile({
    required this.request,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: request.canDecide ? Colors.white : const Color(0xffF4F7F1),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: CheckboxListTile(
          value: selected,
          onChanged: request.canDecide ? onChanged : null,
          title: Text(
            '${request.title} · ${request.statusLabel}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(request.subtitle),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}
