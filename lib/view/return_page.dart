import 'package:flutter/material.dart';
import 'package:smart_app/model/return_record.dart';
import 'package:smart_app/repositories/return_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/return_status_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final repository = ReturnRepository();
  final searchController = TextEditingController();
  bool showSearch = false;
  bool isLoading = false;
  String? errorMessage;
  List<ReturnRequestRecord> requests = [];

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
      final records = await repository.fetchReturns();
      if (!mounted) return;
      setState(() => requests = records);
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
    final visible = requests.where((request) {
      return query.isEmpty ||
          '${request.title} ${request.subtitle}'.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: AppScaffold(
        title: '반품 · 환불 관리',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionChipIcon(icon: Icons.refresh, onPressed: isLoading ? null : _load),
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
                hintText: '반품 사유, 상품명을 검색하세요',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
          for (final request in visible)
            _ReturnRequestTile(
              request: request,
              onTap: () async {
                final handled = await Navigator.of(context).push<ReturnRequestRecord>(
                  MaterialPageRoute(
                    builder: (_) => _ReturnDetailPage(request: request),
                  ),
                );
                if (handled != null) {
                  setState(() {
                    final index = requests.indexWhere(
                      (item) => item.returnRequestId == handled.returnRequestId,
                    );
                    if (index >= 0) requests[index] = handled;
                  });
                }
              },
            ),
          if (!isLoading && visible.isEmpty)
            const NoticeBox(color: AppColors.yellow, text: '반품 요청이 없습니다.'),
        ],
      ),
    );
  }
}

class _ReturnRequestTile extends StatelessWidget {
  final ReturnRequestRecord request;
  final VoidCallback onTap;

  const _ReturnRequestTile({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DataTile(
      icon: Icons.keyboard_return,
      title: request.title,
      subtitle: request.subtitle,
      badge: request.statusLabel,
      badgeColor: request.color,
      iconBackground: AppColors.mint,
      iconColor: AppColors.green,
      onTap: onTap,
      showChevron: true,
    );
  }
}

class _ReturnDetailPage extends StatefulWidget {
  final ReturnRequestRecord request;

  const _ReturnDetailPage({required this.request});

  @override
  State<_ReturnDetailPage> createState() => _ReturnDetailPageState();
}

class _ReturnDetailPageState extends State<_ReturnDetailPage> {
  final formKey = GlobalKey<FormState>();
  final repository = ReturnRepository();
  late final TextEditingController detailController;
  late final TextEditingController approvalAmountController;
  bool isWorking = false;

  @override
  void initState() {
    super.initState();
    detailController = TextEditingController(text: widget.request.reasonDetail);
    approvalAmountController = TextEditingController(
      text: widget.request.requestedAmount.toString(),
    );
  }

  @override
  void dispose() {
    detailController.dispose();
    approvalAmountController.dispose();
    super.dispose();
  }

  Future<void> _confirmApprove(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 항목을 입력해야 승인 가능합니다.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '반품 요청 승인',
      message: '반품 · 환불 상태를 승인 처리할까요?',
      confirmLabel: '승인',
      onConfirm: _approve,
    );
  }

  Future<void> _approve() async {
    setState(() => isWorking = true);
    try {
      final updated = await repository.approve(
        request: widget.request,
        approvedAmount: int.parse(approvalAmountController.text.trim()),
      );
      if (!mounted) return;
      returnStatusRecords.insert(
        0,
        ReturnStatusRecord(
          updated.requestedAt,
          '${updated.customerName} · ${updated.productName} · ${updated.approvedAmount}원',
          updated.statusLabel,
          updated.color,
          returnRequestId: updated.returnRequestId,
        ),
      );
      showOwnerSnack(context, '반품 현황을 갱신했습니다.');
      Navigator.of(context).pop(updated);
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isWorking = false);
    }
  }

  Future<void> _confirmReject(BuildContext context) async {
    var reason = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('반품 요청 거절'),
              content: DropdownButtonFormField<String>(
                initialValue: reason,
                items: const [
                  DropdownMenuItem(value: '', child: Text('선택하세요')),
                  DropdownMenuItem(value: '고객 단순 변심', child: Text('고객 단순 변심')),
                  DropdownMenuItem(value: '첨부 이미지 확인 불가', child: Text('첨부 이미지 확인 불가')),
                  DropdownMenuItem(value: '환불 정책 대상 아님', child: Text('환불 정책 대상 아님')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => reason = value);
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
    if (confirmed == true) await _reject(reason);
  }

  Future<void> _reject(String reason) async {
    setState(() => isWorking = true);
    try {
      final updated = await repository.reject(
        request: widget.request,
        reason: reason,
      );
      if (!mounted) return;
      returnStatusRecords.insert(
        0,
        ReturnStatusRecord(
          updated.requestedAt,
          '${updated.customerName} · ${updated.productName} · $reason',
          updated.statusLabel,
          updated.color,
          returnRequestId: updated.returnRequestId,
        ),
      );
      showOwnerSnack(context, '반품 현황을 갱신했습니다.');
      Navigator.of(context).pop(updated);
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '반품 · 환불 상세',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            DataTile(
              icon: Icons.keyboard_return,
              title: widget.request.title,
              subtitle: widget.request.subtitle,
              badge: widget.request.statusLabel,
              badgeColor: widget.request.color,
              iconBackground: const Color(0xffFFE1DD),
              iconColor: const Color(0xffB64033),
            ),
            LabeledField(
              label: '구매 상품 금액',
              value: '${widget.request.requestedAmount}원',
              enabled: false,
            ),
            LabeledField(
              label: '고객 요청 사유',
              value: ReturnRequestRecord.reasonLabel(widget.request.reasonCode),
              enabled: false,
            ),
            LabeledBox(
              label: '상세 사유',
              value: widget.request.reasonDetail,
              controller: detailController,
              enabled: false,
            ),
            if (widget.request.photoCount > 0)
              _CustomerImagePreview(count: widget.request.photoCount),
            LabeledField(
              label: '승인 금액',
              value: '',
              controller: approvalAmountController,
              hintText: '승인 금액',
              keyboardType: TextInputType.number,
              inputFormatters: const [DigitsOnlyInputFormatter()],
              validator: (text) {
                final required = requiredValidator('승인 금액', text);
                if (required != null) return required;
                return RegExp(r'^\d+$').hasMatch(text!.trim())
                    ? null
                    : '승인 금액에는 숫자만 입력하세요.';
              },
              suffixText: '원',
            ),
            DualActionBar(
              left: isWorking ? '처리 중' : '거절',
              right: isWorking ? '처리 중' : '승인',
              onLeftPressed: isWorking ? null : () => _confirmReject(context),
              onRightPressed: isWorking ? null : () => _confirmApprove(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerImagePreview extends StatelessWidget {
  final int count;

  const _CustomerImagePreview({required this.count});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xffB64033), Color(0xffF1B095)],
              ),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
      ],
    );
  }
}
