import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/category/presentation/providers/categories_provider.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/features/inventory/presentation/widgets/inventory_adjustment_modal.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Bulk Import',
            onPressed: () => context.push('/products/import'),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final barcode = await context.pushNamed('scanner');
              if (!mounted) return;
              if (barcode != null && barcode is String) {
                // If scanner returned a barcode (meaning product wasn't found),
                // we navigate to add product with barcode pre-filled.
                // Wait, we need to pass this to add. We can pass a dummy model or query param.
                // For now, let's just go to add and let user type, or we could modify form to accept barcode.
                context.push('/products/add', extra: {'barcode': barcode});
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(productsProvider.notifier).setSearchQuery('');
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                  onSubmitted: (value) {
                    ref.read(productsProvider.notifier).setSearchQuery(value);
                  },
                ),
              ),
              // Categories Filter
              SizedBox(
                height: 40,
                child: categoriesState.when(
                  data: (categories) => ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All'),
                          selected: state.categoryId == null,
                          onSelected: (val) => val ? ref.read(productsProvider.notifier).setCategoryFilter(null) : null,
                        ),
                      ),
                      ...categories.map((c) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c.name),
                              selected: state.categoryId == c.id,
                              onSelected: (val) => val ? ref.read(productsProvider.notifier).setCategoryFilter(c.id) : null,
                            ),
                          ))
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/add'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productsProvider.notifier).fetchProducts(refresh: true),
        child: state.products.when(
          data: (products) {
            if (products.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(child: Text('No products found.')),
                ),
              );
            }
            return ListView.separated(
              controller: _scrollController,
              itemCount: products.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == products.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final product = products[index];
                final isLowStock = product.quantity <= product.lowStockThreshold;

                return ListTile(
                  title: Text(product.name, style: AppTextStyles.bodyLarge),
                  subtitle: Text('Stock: ${product.quantity} ${product.unitType} | ₹${product.sellingPrice}'),
                  onTap: () => context.push('/products/details', extra: product),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLowStock)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Low', style: AppTextStyles.caption.copyWith(color: AppColors.error)),
                        ),
                      IconButton(
                        icon: const Icon(Icons.inventory_2_outlined, color: AppColors.accent),
                        tooltip: 'Adjust Stock',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => InventoryAdjustmentModal(product: product),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Failed to load: $err')),
        ),
      ),
    );
  }
}
