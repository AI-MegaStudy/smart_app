import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_app/vm/dashboard_viewmodel.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _didLoadDashboard = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_didLoadDashboard) {
      _didLoadDashboard = true;
      final viewModel = context.read<DashboardViewModel>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadDashboard();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('점주 대시보드'),
        actions: [
          IconButton(
            onPressed: () {
              vm.loadDashboard();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.errorMessage != null
            ? _DashboardError(
                message: vm.errorMessage!,
                onRetry: vm.loadDashboard,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘 처리할 업무',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth >= 720
                            ? 3
                            : 2;

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.2,
                          children: [
                            _DashboardCard(
                              title: '열린 슬롯',
                              value: vm.dashboard?.openSlots ?? 0,
                              icon: Icons.event_available,
                            ),
                            _DashboardCard(
                              title: '신규 발주',
                              value: vm.dashboard?.newProcurements ?? 0,
                              icon: Icons.assignment,
                            ),
                            _DashboardCard(
                              title: '선별 대기',
                              value: vm.dashboard?.inspectionWaiting ?? 0,
                              icon: Icons.camera_alt,
                            ),
                            _DashboardCard(
                              title: '배송 준비',
                              value: vm.dashboard?.readyToShip ?? 0,
                              icon: Icons.local_shipping,
                            ),
                            _DashboardCard(
                              title: '반품 요청',
                              value: vm.dashboard?.returnRequests ?? 0,
                              icon: Icons.keyboard_return,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34, color: Colors.green),
            const Spacer(),
            Text(
              '$value',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
