import 'package:flutter/material.dart';
import 'package:smart_app/model/product_record.dart';
import 'package:smart_app/repositories/product_repository.dart';
import 'package:smart_app/util/app_colors.dart';
import 'package:smart_app/view/product_add_page.dart';
import 'package:smart_app/view/product_edit_page.dart';
import 'package:smart_app/widgets/owner_widgets.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final repository = ProductRepository();
  final searchController = TextEditingController();
  final selectedProducts = <ProductRecord>{};

  String filter = '전체';
  bool showSearch = false;
  bool deleteMode = false;
  bool isLoading = false;
  String? errorMessage;
  List<ProductRecord> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final records = await repository.fetchProducts();
      if (!mounted) return;
      setState(() => products = records);
    } catch (error) {
      if (!mounted) return;
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _openAdd() async {
    final product = await Navigator.of(context).push<ProductRecord>(
      MaterialPageRoute(builder: (_) => const ProductAddPage()),
    );
    if (product == null) return;
    setState(() {
      deleteMode = false;
      selectedProducts.clear();
      products.insert(0, product);
    });
  }

  Future<void> _openEdit(ProductRecord product) async {
    final updated = await Navigator.of(context).push<ProductRecord>(
      MaterialPageRoute(builder: (_) => ProductEditPage(product: product)),
    );
    if (updated == null) return;
    setState(() {
      final index = products.indexWhere(
        (item) => item.productId == updated.productId,
      );
      if (index >= 0) {
        products[index] = updated;
      }
    });
  }

  Future<void> _hideSelectedProducts() async {
    final selected = selectedProducts.toList();
    try {
      for (final product in selected) {
        final updated = await repository.updateProductStatus(
          product: product,
          statusCode: 'HIDDEN',
        );
        final index = products.indexWhere(
          (item) => item.productId == updated.productId,
        );
        if (index >= 0) {
          products[index] = updated;
        }
      }
      if (!mounted) return;
      setState(() {
        selectedProducts.clear();
        deleteMode = false;
      });
      showOwnerSnack(context, '선택한 상품을 판매 숨김으로 변경했습니다.');
    } catch (error) {
      if (!mounted) return;
      showOwnerSnack(context, error.toString());
    }
  }

  void _toggleDeleteMode() {
    if (!deleteMode) {
      setState(() => deleteMode = true);
      return;
    }
    if (selectedProducts.isEmpty) {
      showOwnerSnack(context, '숨김 처리할 상품을 선택하세요.');
      return;
    }
    showConfirmAction(
      context: context,
      title: '상품 숨김',
      message: '선택한 ${selectedProducts.length}개 상품을 판매 숨김으로 변경할까요?',
      confirmLabel: '숨김',
      onConfirm: _hideSelectedProducts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final visible = products.where((product) {
      final matchesFilter = filter == '전체' || product.status == filter;
      final searchable =
          '${product.name} ${product.variety} ${product.packageUnit} '
          '${product.priceLabel} ${product.status}';
      final matchesQuery =
          query.isEmpty || searchable.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      body: AppScaffold(
        title: '상품 관리',
        leading: ActionChipIcon(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionChipIcon(
              icon: Icons.refresh,
              onPressed: isLoading ? null : _loadProducts,
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
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage != null)
            NoticeBox(color: const Color(0xffFFE9E2), text: errorMessage!),
          FilterTabs(
            labels: const ['전체', '판매 중', '준비 중', '판매 중지'],
            selected: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          if (!isLoading && visible.isEmpty)
            const NoticeBox(
              color: Color(0xffF4F7F1),
              text: '표시할 상품이 없습니다.',
            ),
          for (final product in visible)
            deleteMode
                ? _ProductDeleteTile(
                    product: product,
                    selected: selectedProducts.contains(product),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedProducts.add(product);
                        } else {
                          selectedProducts.remove(product);
                        }
                      });
                    },
                  )
                : _ProductTile(
                    product: product,
                    onTap: () => _openEdit(product),
                  ),
          if (deleteMode)
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (selectedProducts.length == visible.length) {
                        selectedProducts.clear();
                      } else {
                        selectedProducts
                          ..clear()
                          ..addAll(visible);
                      }
                    });
                  },
                  child: Text(
                    visible.isNotEmpty &&
                            selectedProducts.length == visible.length
                        ? '전체 선택 해제'
                        : '전체 선택',
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _toggleDeleteMode,
                  child: const Text('숨김'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    deleteMode = false;
                    selectedProducts.clear();
                  }),
                  child: const Text('완료'),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _toggleDeleteMode,
                child: const Text('상품 숨김'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductRecord product;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.onTap});

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
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_florist, color: AppColors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.name} · ${product.packageUnit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.priceLabel} · 열린 슬롯 ${product.stockKg}개',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusBadge(text: product.status, color: product.color),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductDeleteTile extends StatelessWidget {
  final ProductRecord product;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  const _ProductDeleteTile({
    required this.product,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: onChanged,
      title: Text(
        '${product.name} · ${product.packageUnit}',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text('${product.priceLabel} · ${product.status}'),
      controlAffinity: ListTileControlAffinity.leading,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
