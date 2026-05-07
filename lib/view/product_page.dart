import 'package:flutter/material.dart';
import 'package:smart_app/model/product_record.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/product_add_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final searchController = TextEditingController();
  String filter = '전체';
  bool showSearch = false;
  bool deleteMode = false;
  final selectedProducts = <ProductRecord>{};

  final products = [
    const ProductRecord(
      '후지 사과',
      '5kg 박스',
      '39,000원 · 수확 슬롯 2개',
      '판매 중',
      AppColors.mint,
    ),
    const ProductRecord(
      '홍로 사과',
      '3kg 박스',
      '32,000원 · 잔여 42kg',
      '준비 중',
      AppColors.yellow,
    ),
    const ProductRecord(
      '시나노골드 사과',
      '7kg 박스',
      '68,000원 · 사고 재고 확인 필요',
      '중지',
      Color(0xffFFE1DD),
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    final product = await Navigator.of(context).push<ProductRecord>(
      MaterialPageRoute(builder: (_) => const ProductAddPage()),
    );
    if (product != null) {
      setState(() => products.add(product));
    }
  }

  Future<void> _openEdit(ProductRecord product) async {
    final updated = await Navigator.of(context).push<ProductRecord>(
      MaterialPageRoute(
        builder: (_) => ProductAddPage(initialProduct: product),
      ),
    );
    if (updated != null) {
      setState(() {
        final index = products.indexOf(product);
        if (index >= 0) {
          products[index] = updated;
        }
      });
    }
  }

  void _toggleDeleteMode() {
    if (!deleteMode) {
      setState(() => deleteMode = true);
      return;
    }
    if (selectedProducts.isEmpty) {
      setState(() => deleteMode = false);
      return;
    }
    showConfirmAction(
      context: context,
      title: '상품 삭제',
      message: '선택한 ${selectedProducts.length}개 상품을 삭제할까요?',
      confirmLabel: '삭제',
      onConfirm: () {
        setState(() {
          products.removeWhere(selectedProducts.contains);
          selectedProducts.clear();
          deleteMode = false;
        });
        showOwnerSnack(context, '상품 목록을 갱신했습니다.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final visible = products.where((product) {
      final matchesFilter = filter == '전체' || product.status == filter;
      final matchesQuery =
          query.isEmpty ||
          '${product.name} ${product.packageUnit} ${product.summary} ${product.status}'
              .toLowerCase()
              .contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      body: AppScaffold(
        title: '상품 관리',
        subtitle: '포장 단위와 가격 관리',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionChipIcon(
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
            const SizedBox(width: 6),
            ActionChipIcon(icon: Icons.add, onPressed: _openAdd),
          ],
        ),
        children: [
          if (showSearch)
            TextField(
              controller: searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '상품명, 포장 단위, 상태를 검색하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          FilterTabs(
            labels: const ['전체', '판매 중', '준비 중', '중지'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          for (final product in visible)
            deleteMode
                ? CheckboxListTile(
                    value: selectedProducts.contains(product),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedProducts.add(product);
                        } else {
                          selectedProducts.remove(product);
                        }
                      });
                    },
                    title: Text(
                      '${product.name} · ${product.packageUnit}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(product.summary),
                    controlAffinity: ListTileControlAffinity.leading,
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  )
                : DataTile(
                    icon: Icons.local_florist,
                    title: '${product.name} · ${product.packageUnit}',
                    subtitle: product.summary,
                    badge: product.status,
                    badgeColor: product.color,
                    onTap: () => _openEdit(product),
                  ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _toggleDeleteMode,
              child: Text(deleteMode ? '완료' : '삭제'),
            ),
          ),
        ],
      ),
    );
  }
}
