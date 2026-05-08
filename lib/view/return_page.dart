import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/return_status_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  final searchController = TextEditingController();
  bool showSearch = false;

  final requests = [
    _ReturnRequest('배송 중 파손', '양광 사과 5kg · 2026-05-07 09:30', '접수', 2),
    _ReturnRequest('상품 멍 확인', '부사 사과 3kg · 2026-05-07 10:10', '접수', 1),
    _ReturnRequest('수량 오배송', '양광 사과 7kg · 2026-05-07 11:40', '접수', 0),
  ].where((request) => !_handledReturnTitles.contains(request.title)).toList();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        subtitle: '고객 요청 목록',
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
                hintText: '반품 사유, 상품명을 검색하세요',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          for (final request in visible)
            _ReturnRequestTile(
              request: request,
              onTap: () async {
                final handled = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => _ReturnDetailPage(request: request),
                  ),
                );
                if (handled == true) {
                  setState(() {
                    requests.remove(request);
                    _handledReturnTitles.add(request.title);
                  });
                }
              },
            ),
        ],
      ),
    );
  }
}

final _handledReturnTitles = <String>{};

class _ReturnRequestTile extends StatelessWidget {
  final _ReturnRequest request;
  final VoidCallback onTap;

  const _ReturnRequestTile({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xffFFE1DD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.keyboard_return,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReturnDetailPage extends StatefulWidget {
  final _ReturnRequest request;

  const _ReturnDetailPage({required this.request});

  @override
  State<_ReturnDetailPage> createState() => _ReturnDetailPageState();
}

class _ReturnDetailPageState extends State<_ReturnDetailPage> {
  final formKey = GlobalKey<FormState>();
  final detailController = TextEditingController();
  final approvalAmountController = TextEditingController();

  @override
  void dispose() {
    detailController.dispose();
    approvalAmountController.dispose();
    super.dispose();
  }

  void _confirmApprove(BuildContext context) {
    if (!(formKey.currentState?.validate() ?? false)) {
      showOwnerSnack(context, '모든 항목을 입력해야 승인 가능합니다.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '반품 요청 승인',
      message: '반품 · 환불 상태를 환불 승인 처리할까요?',
      confirmLabel: '환불 승인',
      onConfirm: () {
        returnStatusRecords.add(
          ReturnStatusRecord(
            widget.request.title,
            '${widget.request.subtitle} · ${approvalAmountController.text}원',
            '승인',
            AppColors.mint,
          ),
        );
        showOwnerSnack(context, '반품 현황을 갱신했습니다.');
        Navigator.of(context).pop(true);
      },
    );
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
                  DropdownMenuItem(value: '', child: Text('선택하세요.')),
                  DropdownMenuItem(value: '고객 단순 변심', child: Text('고객 단순 변심')),
                  DropdownMenuItem(
                    value: '첨부 이미지 확인 불가',
                    child: Text('첨부 이미지 확인 불가'),
                  ),
                  DropdownMenuItem(
                    value: '환불 정책 대상 아님',
                    child: Text('환불 정책 대상 아님'),
                  ),
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
    if (confirmed == true && context.mounted) {
      returnStatusRecords.add(
        ReturnStatusRecord(
          widget.request.title,
          '${widget.request.subtitle} · $reason',
          '거절',
          AppColors.yellow,
        ),
      );
      showOwnerSnack(context, '반품 현황을 갱신했습니다.');
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScaffold(
          title: '반품 · 환불 상세',
          subtitle: '요청 확인과 결정',
          leading: ActionChipIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
          children: [
            DataTile(
              icon: Icons.keyboard_return,
              title: widget.request.title,
              subtitle: widget.request.subtitle,
              badge: widget.request.status,
              badgeColor: const Color(0xffFFE1DD),
            ),
            const LabeledField(
              label: '구매 상품 금액',
              value: '39,000원',
              enabled: false,
            ),
            const LabeledField(
              label: '고객 요청 사유',
              value: '배송 중 박스 파손',
              enabled: false,
            ),
            LabeledBox(
              label: '상세 사유',
              value: '',
              controller: detailController,
              hintText: '상세 사유',
            ),
            if (widget.request.photoCount > 0)
              _CustomerImagePreview(count: widget.request.photoCount),
            LabeledField(
              label: '승인 금액',
              value: '',
              controller: approvalAmountController,
              hintText: '승인 금액',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              regexHint: '숫자만 입력',
              validator: (text) {
                final base = numericValidator(text);
                return base == null ? null : '승인 금액에는 숫자만 입력하세요.';
              },
              suffixText: '원',
            ),
            DualActionBar(
              left: '거절',
              right: '환불 승인',
              onLeftPressed: () => _confirmReject(context),
              onRightPressed: () => _confirmApprove(context),
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

class _ReturnRequest {
  final String title;
  final String subtitle;
  final String status;
  final int photoCount;

  const _ReturnRequest(this.title, this.subtitle, this.status, this.photoCount);
}
