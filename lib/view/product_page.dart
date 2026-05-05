import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/product_add_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String filter = '전체';

  final products = const [
    _Product('홍로 사과 5kg', '39,000원 · 수확 슬롯 2개', '판매 중', AppColors.mint),
    _Product('부사 사과 3kg', '32,000원 · 잔여 42kg', '준비 중', AppColors.yellow),
    _Product('시나노골드 7.5kg', '68,000원 · 재고 점검 필요', '중지', Color(0xffFFE1DD)),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = filter == '전체'
        ? products
        : products.where((product) => product.status == filter).toList();

    return Scaffold(
      body: AppScaffold(
        title: '상품 관리',
        subtitle: '포장 단위와 가격 관리',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: ActionChipIcon(
          icon: Icons.add,
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProductAddPage()));
          },
        ),
        children: [
          FilterTabs(
            labels: const ['전체', '판매 중', '준비 중', '중지'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          for (final product in visible)
            DataTile(
              icon: Icons.local_florist,
              title: product.title,
              subtitle: product.subtitle,
              badge: product.status,
              badgeColor: product.color,
            ),
        ],
      ),
    );
  }
}

class _Product {
  final String title;
  final String subtitle;
  final String status;
  final Color color;

  const _Product(this.title, this.subtitle, this.status, this.color);
}
