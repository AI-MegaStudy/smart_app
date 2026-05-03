import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/harvest_slot_page.dart';
import 'package:smart_app/view/orders_page.dart';
import 'package:smart_app/view/procurement_page.dart';
import 'package:smart_app/view/product_page.dart';
import 'package:smart_app/view/quality_page.dart';
import 'package:smart_app/view/return_page.dart';
import 'package:smart_app/view/shipment_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '메뉴',
      subtitle: '점주 운영 업무 전체',
      trailing: ActionChipIcon(
        icon: Icons.search,
        onPressed: () => showOwnerSnack(context, '메뉴 검색을 준비합니다.'),
      ),
      children: [
        const NoticeBox(
          color: AppColors.blue,
          text: '문서와 목업 기준의 점주 업무 화면입니다. 필요한 업무를 선택해 상세 화면으로 이동하세요.',
        ),
        MenuSection(
          title: '기본 관리',
          items: [
            MenuEntry(
              icon: Icons.local_florist_outlined,
              title: '상품 관리',
              subtitle: '판매 상품 등록, 포장 단위, 가격 관리',
              page: const ProductPage(),
            ),
            MenuEntry(
              icon: Icons.auto_graph_outlined,
              title: '수확 예측 · 슬롯 확정',
              subtitle: 'ML 예측 확인 후 고객 예약 슬롯 확정',
              page: const HarvestSlotPage(),
            ),
          ],
        ),
        MenuSection(
          title: '주문 처리',
          items: [
            MenuEntry(
              icon: Icons.receipt_long_outlined,
              title: '예약 · 주문 현황',
              subtitle: '고객 예약과 주문 상태 확인',
              page: const OrdersPage(),
            ),
            MenuEntry(
              icon: Icons.inventory_2_outlined,
              title: '발주 승인',
              subtitle: '발주 목록 확인, 승인, 부분 승인, 거절',
              page: const ProcurementPage(),
            ),
            MenuEntry(
              icon: Icons.center_focus_strong_outlined,
              title: '신선도 검사',
              subtitle: '촬영, DL 결과 확인, 점주 최종 판정',
              page: const QualityPage(),
            ),
          ],
        ),
        MenuSection(
          title: '배송 · 반품',
          items: [
            MenuEntry(
              icon: Icons.local_shipping_outlined,
              title: '배송 관리',
              subtitle: '택배사, 송장 번호, 발송 수량 등록',
              page: const ShipmentPage(),
            ),
            MenuEntry(
              icon: Icons.keyboard_return_outlined,
              title: '반품 · 환불 관리',
              subtitle: '반품 요청 확인, 승인/거절, 환불 처리',
              page: const ReturnPage(),
            ),
          ],
        ),
      ],
    );
  }
}

class MenuSection extends StatelessWidget {
  final String title;
  final List<MenuEntry> items;

  const MenuSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 10),
        for (var i = 0; i < items.length; i++) ...[
          _MenuTile(entry: items[i]),
          if (i != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class MenuEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;

  const MenuEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
  });
}

class _MenuTile extends StatelessWidget {
  final MenuEntry entry;

  const _MenuTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => entry.page));
        },
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
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(entry.icon, color: AppColors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
