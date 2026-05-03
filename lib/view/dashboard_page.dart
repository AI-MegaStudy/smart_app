import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/widgets/owner_widgets.dart';
import 'package:smart_app/vm/dashboard_viewmodel.dart';

class DashboardPage extends StatefulWidget {
  final ValueChanged<int> onJump;

  const DashboardPage({super.key, required this.onJump});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _didLoadDashboard = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDashboard) {
      return;
    }
    _didLoadDashboard = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final dashboard = vm.dashboard;

    return AppScaffold(
      title: '안녕하세요, 김점주님',
      subtitle: '충주 햇살농원',
      trailing: IconButton.filled(
        onPressed: () => widget.onJump(2),
        icon: const Text('김', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      children: [
        HeroPanel(
          eyebrow: '오늘 우선 처리',
          title:
              '발주 ${dashboard?.newProcurements ?? 4}건과 선별 ${dashboard?.inspectionWaiting ?? 7}건이 기다립니다',
          icon: Icons.spa,
        ),
        GridCards(
          children: [
            MetricCard(
              icon: Icons.event_available_outlined,
              value: '${dashboard?.openSlots ?? 6}',
              label: '열린 수확 슬롯',
              onTap: () => widget.onJump(0),
            ),
            MetricCard(
              icon: Icons.assignment_turned_in_outlined,
              value: '${dashboard?.newProcurements ?? 4}',
              label: '신규 발주',
              onTap: () => widget.onJump(0),
            ),
            MetricCard(
              icon: Icons.center_focus_strong_outlined,
              value: '${dashboard?.inspectionWaiting ?? 7}',
              label: '선별 대기',
              onTap: () => widget.onJump(0),
            ),
            MetricCard(
              icon: Icons.local_shipping_outlined,
              value: '${dashboard?.readyToShip ?? 3}',
              label: '배송 준비',
              onTap: () => widget.onJump(0),
            ),
          ],
        ),
        SectionHeader(
          title: '긴급 확인',
          actionText: '${dashboard?.returnRequests ?? 2}건',
        ),
        DataTile(
          icon: Icons.local_florist,
          title: '후지 5kg 발주 승인',
          subtitle: '홍길동 고객 · 2박스',
          badge: '대기',
          badgeColor: AppColors.yellow,
          onTap: () => widget.onJump(0),
        ),
        DataTile(
          icon: Icons.keyboard_return,
          title: '배송 중 파손',
          subtitle: '사진 2장 첨부 · 환불 검토',
          badge: '확인 필요',
          badgeColor: const Color(0xffFFE1DD),
          onTap: () => widget.onJump(0),
        ),
      ],
    );
  }
}
