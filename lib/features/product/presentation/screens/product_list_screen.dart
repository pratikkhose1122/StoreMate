import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/category/presentation/providers/categories_provider.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/core/widgets/app_text_field.dart';
import 'package:storemate/core/widgets/app_chip.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';
import 'package:storemate/core/widgets/app_shimmer.dart';
import 'package:storemate/features/product/presentation/widgets/add_product_bottom_sheet.dart';
import 'package:decimal/decimal.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _selectedFilter = 'All'; 

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file_outlined, size: 20, color: colors.textSecondary),
            tooltip: 'Bulk Import',
            onPressed: () => context.push('/products/import'),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 22, color: colors.primary),
            tooltip: 'Add Product',
            onPressed: () => AddProductBottomSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search & Filters ──
            Container(
              color: colors.background,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                children: [
                  AppTextField(
                    controller: _searchController,
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, size: 20, color: colors.textTertiary),
                    suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18, color: colors.textTertiary),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(productsProvider.notifier).setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    onChanged: (value) {
                      ref.read(productsProvider.notifier).setSearchQuery(value);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AppChip(
                            label: 'All',
                            isSelected: _selectedFilter == 'All' && state.categoryId == null,
                            onTap: () {
                              setState(() => _selectedFilter = 'All');
                              ref.read(productsProvider.notifier).setCategoryFilter(null);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AppChip(
                            label: 'Low Stock',
                            isSelected: _selectedFilter == 'Low Stock',
                            onTap: () {
                              setState(() => _selectedFilter = 'Low Stock');
                              ref.read(productsProvider.notifier).setCategoryFilter(null);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AppChip(
                            label: 'Out of Stock',
                            isSelected: _selectedFilter == 'Out of Stock',
                            onTap: () {
                              setState(() => _selectedFilter = 'Out of Stock');
                              ref.read(productsProvider.notifier).setCategoryFilter(null);
                            },
                          ),
                        ),
                        categoriesState.when(
                          data: (categories) => Row(
                            children: categories.map((c) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: AppChip(
                                label: c.name,
                                isSelected: state.categoryId == c.id,
                                onTap: () {
                                  setState(() => _selectedFilter = c.name);
                                  ref.read(productsProvider.notifier).setCategoryFilter(c.id);
                                },
                              ),
                            )).toList(),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (a, b) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // ── Product List ──
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(productsProvider.notifier).fetchProducts(refresh: true),
                color: colors.primary,
                child: state.products.when(
                  data: (products) {
                    var displayList = products;
                    if (_selectedFilter == 'Low Stock') {
                      displayList = products.where((p) => p.quantity <= p.lowStockThreshold && p.quantity > Decimal.zero).toList();
                    } else if (_selectedFilter == 'Out of Stock') {
                      displayList = products.where((p) => p.quantity <= Decimal.zero).toList();
                    }

                    if (displayList.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 40),
                          AppEmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'No products found',
                            explanation: 'Try adjusting your filters or add a new product.',
                            actionLabel: 'Add Product',
                            onAction: () => AddProductBottomSheet.show(context),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: displayList.length + (state.hasMore || state.paginationError != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayList.length) {
                          if (state.paginationError != null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  Text('Couldn\'t load more products', style: AppTextStyles.bodySm.copyWith(color: colors.danger)),
                                  TextButton(
                                    onPressed: () => ref.read(productsProvider.notifier).fetchProducts(),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: List.generate(2, (_) => const ShimmerProductRow()),
                          );
                        }
                        
                        final product = displayList[index];
                        final isOutOfStock = product.quantity <= Decimal.zero;
                        final isLowStock = product.quantity <= product.lowStockThreshold && !isOutOfStock;

                        return InkWell(
                          onTap: () => context.push('/products/details', extra: product),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: colors.border, width: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Image
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: product.imageUrl == null || product.imageUrl!.isEmpty 
                                        ? colors.primary.withValues(alpha: 0.1) 
                                        : colors.elevatedCard,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            product.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Center(
                                              child: Text(
                                                product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                                                style: AppTextStyles.titleSm.copyWith(color: colors.primary),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                                            style: AppTextStyles.titleSm.copyWith(color: colors.primary),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Name + Brand
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (product.brand != null && product.brand!.isNotEmpty)
                                        Text(
                                          product.brand!,
                                          style: AppTextStyles.bodySm.copyWith(color: colors.textTertiary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Price
                                Text(
                                  '₹${product.sellingPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.monoSm.copyWith(color: colors.textPrimary),
                                ),
                                const SizedBox(width: 16),

                                // Stock + Status
                                SizedBox(
                                  width: 56,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isOutOfStock
                                              ? colors.danger
                                              : isLowStock
                                                  ? colors.warning
                                                  : colors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${product.quantity}',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: isOutOfStock
                                              ? colors.danger
                                              : isLowStock
                                                  ? colors.warning
                                                  : colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Column(
                    children: List.generate(8, (_) => const ShimmerProductRow()),
                  ),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppEmptyState(
                      icon: Icons.cloud_off,
                      title: 'Unable to load products',
                      explanation: 'Check your connection and try again.',
                      actionLabel: 'Retry',
                      onAction: () => ref.read(productsProvider.notifier).fetchProducts(refresh: true),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
