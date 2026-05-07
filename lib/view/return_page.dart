import 'package:flutter/material.dart';
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
    _ReturnRequest('배송 중 파손', '후지 사과 5kg · 사진 2장 첨부', '확인 필요'),
    _ReturnRequest('상품 멍 확인', '홍로 3kg · 사진 1장 첨부', '확인 필요'),
    _ReturnRequest('수량 오배송', '시나노골드 · 고객 메모 확인', '확인 필요'),
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

class _ReturnDetailPage extends StatelessWidget {
  final _ReturnRequest request;

  const _ReturnDetailPage({required this.request});

  void _confirmApprove(BuildContext context) {
    showConfirmAction(
      context: context,
      title: '반품 요청 승인',
      message: '반품 · 환불 상태를 환불 승인 처리할까요?',
      confirmLabel: '환불 승인',
      onConfirm: () {
        returnStatusRecords.add(
          ReturnStatusRecord(
            request.title,
            request.subtitle,
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
    var reason = '고객 단순 변심';
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
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('거절'),
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
          request.title,
          '${request.subtitle} · $reason',
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
      body: AppScaffold(
        title: '반품 · 환불 상세',
        subtitle: '요청 확인과 결정',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        children: [
          DataTile(
            icon: Icons.keyboard_return,
            title: request.title,
            subtitle: request.subtitle,
            badge: request.status,
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
          const LabeledBox(
            label: '상세 사유',
            value: '박스 외부 파손과 일부 멍이 확인되어 부분 환불합니다.',
            enabled: false,
          ),
          const _CustomerImagePreview(),
          const LabeledField(label: '승인 금액', value: '39,000원'),
          DualActionBar(
            left: '거절',
            right: '환불 승인',
            onLeftPressed: () => _confirmReject(context),
            onRightPressed: () => _confirmApprove(context),
          ),
        ],
      ),
    );
  }
}

class _CustomerImagePreview extends StatelessWidget {
  const _CustomerImagePreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xffB64033), Color(0xffF1B095)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white, size: 52),
      ),
    );
  }
}

class _ReturnRequest {
  final String title;
  final String subtitle;
  final String status;

  const _ReturnRequest(this.title, this.subtitle, this.status);
}
