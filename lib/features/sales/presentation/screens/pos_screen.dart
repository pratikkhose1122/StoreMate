import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/customer/presentation/providers/customers_provider.dart';
import 'package:storemate/features/customer/data/models/customer_model.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/features/sales/data/models/hold_cart_model.dart';
import 'package:storemate/features/sales/presentation/providers/cart_provider.dart';
import 'package:storemate/features/sales/presentation/providers/hold_cart_provider.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';
import 'package:storemate/features/product/data/repositories/product_repository.dart';
import 'package:decimal/decimal.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  
  bool _isSearching = false;
  String _searchQuery = '';
  List<ProductModel> _searchResults = [];
  bool _isSearchLoading = false;
  
  bool _isViewingCart = true; // Default to true to show cart if not empty, similar to old behavior

  String _selectedPaymentMethod = 'cash';
  bool _isCheckoutLoading = false;
  String? _currentIntentId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      setState(() {
        _searchQuery = query.trim();
        _isSearching = _searchQuery.isNotEmpty;
        _isSearchLoading = true;
      });

      if (_searchQuery.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearchLoading = false;
        });
        return;
      }

      try {
        final result = await ref.read(productRepositoryProvider).getProducts(search: _searchQuery, limit: 10);
        if (mounted && _searchQuery == query.trim()) {
          setState(() {
            _searchResults = (result['items'] as List<dynamic>).cast<ProductModel>();
            _isSearchLoading = false;
          });
        }
      } catch (e) {
        if (mounted && _searchQuery == query.trim()) {
          setState(() => _isSearchLoading = false);
        }
      }
    });
  }

  void _addManualItem() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final gstCtrl = TextEditingController(text: '0');
    bool showMore = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.card,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add Manual Item', style: AppTextStyles.titleLg.copyWith(color: context.colors.textPrimary)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setModalState(() => showMore = !showMore),
                  child: Text(showMore ? 'Hide Options' : 'More Options (GST)', style: TextStyle(color: context.colors.primary)),
                ),
                if (showMore)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: gstCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: context.colors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'GST % (Optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final price = Decimal.tryParse(priceCtrl.text) ?? Decimal.zero;
                          final qty = Decimal.tryParse(qtyCtrl.text) ?? Decimal.one;
                          final gst = Decimal.tryParse(gstCtrl.text) ?? Decimal.zero;
                          
                          if (name.isNotEmpty && price > Decimal.zero) {
                            ref.read(cartProvider.notifier).addManualItem(name: name, price: price, quantity: qty, taxPercentage: gst);
                            Navigator.pop(ctx);
                            _searchController.clear();
                            _onSearchChanged('');
                            _searchFocusNode.unfocus();
                          }
                        },
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Sell Only'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final price = Decimal.tryParse(priceCtrl.text) ?? Decimal.zero;
                          final qty = Decimal.tryParse(qtyCtrl.text) ?? Decimal.one;
                          final gst = Decimal.tryParse(gstCtrl.text) ?? Decimal.zero;
                          
                          if (name.isNotEmpty && price > Decimal.zero) {
                            // Save to inventory
                            try {
                              final savedProduct = await ref.read(productsProvider.notifier).addProduct({
                                'name': name,
                                'sellingPrice': price.toString(),
                                'purchasePrice': price.toString(),
                                'quantity': qty.toString(),
                                'lowStockThreshold': '5',
                                'unitType': 'piece',
                                'status': 'active',
                                'taxPercentage': gst.toString(),
                              });
                              // Instantly add to cart
                              if (mounted) {
                                ref.read(cartProvider.notifier).addProduct(savedProduct, quantity: qty);
                                Navigator.pop(ctx);
                              }
                              _searchController.clear();
                              _onSearchChanged('');
                              _searchFocusNode.unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to inventory & added to cart!'), backgroundColor: Colors.green));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: context.colors.primary, foregroundColor: Colors.white),
                        child: const Text('Save to Inventory'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
      ),
    );
  }

  Future<void> _showEditQuantityDialog(int index, Decimal currentQty) async {
    final String? currentQtyStr = await showDialog<String>(
      context: context,
      builder: (ctx) => _QuantityInputDialog(
        initialValue: currentQty.toString(),
      ),
    );
    if (currentQtyStr != null && double.tryParse(currentQtyStr) != null) {
      if (!mounted) return;
      final newQty = Decimal.tryParse(currentQtyStr) ?? Decimal.zero;
      final cartState = ref.read(cartProvider);
      final product = cartState.items[index].product;
      if (product != null && newQty > product.quantity) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
           content: Text('Only ${product.quantity} units available'),
           behavior: SnackBarBehavior.floating,
         ));
      }
      ref.read(cartProvider.notifier).updateQuantity(index, newQty);
    }
  }

  void _selectCustomerDialog() {
    // Basic bottom sheet for customers
    final customers = ref.read(customersProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Walk-in Customer', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
              onTap: () {
                ref.read(cartProvider.notifier).clearCustomer();
                Navigator.pop(ctx);
              },
            ),
            const Divider(),
            if (customers.isEmpty)
              Padding(padding: const EdgeInsets.all(16), child: Text('No customers found', style: TextStyle(color: context.colors.textSecondary)))
            else
              ...customers.take(5).map((c) => ListTile(
                title: Text(c.name, style: TextStyle(color: context.colors.textPrimary)),
                subtitle: Text(c.mobileNumber ?? '', style: TextStyle(color: context.colors.textSecondary)),
                onTap: () {
                  ref.read(cartProvider.notifier).setCustomer(c.id);
                  Navigator.pop(ctx);
                },
              )),
          ],
        ),
      ),
    );
  }

  Future<void> _processCheckout() async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) return;

    if (_selectedPaymentMethod == 'credit' && cartState.customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select a customer for credit payment.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isCheckoutLoading = true);
    try {
      _currentIntentId ??= const Uuid().v4();
      final intentId = _currentIntentId!;

      final businessTimestamp = DateTime.now().toUtc();
      
      final payload = {
        'p_intent_id': intentId,
        'p_customer_id': cartState.customerId,
        'p_business_timestamp': businessTimestamp.toIso8601String(),
        'p_payment_method': _selectedPaymentMethod,
        'p_items': cartState.items.map((i) => ({
          'type': i.isManual ? 'manual' : 'inventory',
          'productId': i.isManual ? null : i.product?.id,
          'productName': i.effectiveName,
          'quantity': i.quantity.toString(),
          'unitPrice': i.effectivePrice.toString(),
          'taxPercentage': i.effectiveTax.toString(),
        })).toList(),
        'p_discount_amount': cartState.totalDiscount.toString(),
        'p_paid_amount': _selectedPaymentMethod == 'credit' ? '0.0' : cartState.totalAmount.toString(),
      };

      final sale = await ref.read(salesRepositoryProvider).checkout(payload);
      
      // Clear intent ID after successful sale
      _currentIntentId = null;
      ref.read(cartProvider.notifier).clearCart();
      
      ref.invalidate(salesHistoryProvider);
      ref.invalidate(productsProvider);
      
      if (mounted) {
        context.push('/sales/success/${sale.id}');
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (mounted) {
        String errorMessage = 'Unable to complete sale. Please check your internet connection and try again.';
        final errorString = e.toString();
        
        if (errorString.contains('P0001')) {
          errorMessage = 'Your shop session is no longer valid. Please refresh and try again.';
        } else if (errorString.contains('P0002')) {
          errorMessage = 'One or more products are invalid or do not belong to this shop.';
        } else if (errorString.contains('P0003')) {
          errorMessage = 'The selected customer is invalid or does not belong to this shop.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isCheckoutLoading = false);
    }
  }

  Future<void> _holdCurrentCart(CartState cartState) async {
    final ctrl = TextEditingController();
    final shouldHold = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hold Cart'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Reference Name (Optional)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hold')),
        ],
      ),
    );

    if (shouldHold == true) {
      final holdCart = HoldCartModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: ctrl.text.trim().isEmpty ? 'Walk-in ${DateTime.now().minute}:${DateTime.now().second}' : ctrl.text.trim(),
        createdAt: DateTime.now(),
        paymentMethod: _selectedPaymentMethod,
        discount: cartState.totalDiscount,
        tax: cartState.totalTax,
        cartItems: cartState.items,
        customer: ref.read(customersProvider).valueOrNull?.cast<CustomerModel?>().firstWhere((c) => c?.id == cartState.customerId, orElse: () => null),
      );

      await ref.read(holdCartProvider.notifier).holdCart(holdCart);
      ref.read(cartProvider.notifier).clearCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart held successfully!')));
      }
    }
  }

  void _showHeldCarts() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final heldCartsAsync = ref.watch(holdCartProvider);
          return SafeArea(
            child: heldCartsAsync.when(
              data: (carts) {
                // Filter out expired carts (older than 24h)
                final validCarts = carts.where((c) => DateTime.now().difference(c.createdAt).inHours < 24).toList();
                
                if (validCarts.isEmpty) {
                  return const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No held carts')));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: validCarts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cart = validCarts[index];
                    final duration = DateTime.now().difference(cart.createdAt);
                    final timeAgo = duration.inMinutes < 60 ? '${duration.inMinutes} min ago' : '${duration.inHours} hours ago';
                    
                    final total = cart.cartItems.fold<Decimal>(Decimal.zero, (sum, item) => sum + (item.effectivePrice * item.quantity));

                    return ListTile(
                      title: Text(cart.name, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                      subtitle: Text('${cart.cartItems.length} Items • ₹$total • $timeAgo', style: TextStyle(color: context.colors.textSecondary)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref.read(holdCartProvider.notifier).deleteCart(cart.id),
                      ),
                      onTap: () {
                        // Restore cart
                        ref.read(cartProvider.notifier).clearCart();
                        if (cart.customer != null) {
                          ref.read(cartProvider.notifier).setCustomer(cart.customer!.id);
                        }
                        for (var item in cart.cartItems) {
                          if (item.isManual) {
                            ref.read(cartProvider.notifier).addManualItem(name: item.effectiveName, price: item.effectivePrice, quantity: item.quantity, taxPercentage: item.effectiveTax);
                          } else if (item.product != null) {
                            ref.read(cartProvider.notifier).addProduct(item.product!, quantity: item.quantity);
                          }
                        }
                        setState(() {
                          _selectedPaymentMethod = cart.paymentMethod;
                        });
                        ref.read(holdCartProvider.notifier).deleteCart(cart.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart restored!')));
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final customers = ref.watch(customersProvider).valueOrNull ?? [];
    
    CustomerModel? currentCustomer;
    if (cartState.customerId != null) {
      currentCustomer = customers.cast<CustomerModel?>().firstWhere((c) => c?.id == cartState.customerId, orElse: () => null);
    }

    return PopScope(
      canPop: !(_isViewingCart && cartState.items.isNotEmpty),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isViewingCart && cartState.items.isNotEmpty) {
          setState(() => _isViewingCart = false);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          leading: (_isViewingCart && cartState.items.isNotEmpty)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _isViewingCart = false),
                )
              : null,
          title: const Text('POS'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final heldCartsAsync = ref.watch(holdCartProvider);
              final count = heldCartsAsync.valueOrNull?.where((c) => DateTime.now().difference(c.createdAt).inHours < 24).length ?? 0;
              if (count == 0) return const SizedBox.shrink();
              
              return IconButton(
                icon: Badge(
                  label: Text('$count'),
                  child: Icon(Icons.inventory_2_outlined, color: context.colors.primary),
                ),
                onPressed: _showHeldCarts,
                tooltip: 'Held Carts',
              );
            },
          ),
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.pause_circle_outline, color: context.colors.primary),
              onPressed: () => _holdCurrentCart(cartState),
              tooltip: 'Hold Cart',
            ),
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: context.colors.danger),
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () => context.push('/pos/scan'),
          backgroundColor: context.colors.primary,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky Search Bar ──
            Container(
              padding: const EdgeInsets.all(12),
              color: context.colors.card,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search product...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary),
                  prefixIcon: Icon(Icons.search, color: context.colors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: context.colors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: context.colors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            
            // ── Main Body (Search Results OR Cart Items) ──
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : (_isViewingCart && cartState.items.isNotEmpty)
                      ? _buildCartList(cartState)
                      : _buildProductCatalog(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (!_isSearching && cartState.items.isNotEmpty)
            ? GestureDetector(
                onTap: () {
                  if (!_isViewingCart) {
                    setState(() => _isViewingCart = true);
                  }
                },
                child: _buildPinnedSummary(cartState, currentCustomer),
              )
            : null,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: context.colors.textTertiary),
            const SizedBox(height: 16),
            Text('No matching products found', style: AppTextStyles.titleMd.copyWith(color: context.colors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addManualItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Manual Item'),
            )
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return ListTile(
          onTap: () {
            ref.read(cartProvider.notifier).addProduct(product);
            if (product.quantity <= Decimal.zero) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Only 0 units available')));
            } else {
              final cartState = ref.read(cartProvider);
              final existingItem = cartState.items.where((i) => i.product?.id == product.id).firstOrNull;
              final newQty = (existingItem?.quantity ?? Decimal.zero) + Decimal.one;
              if (newQty > product.quantity) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Only ${product.quantity} units available'),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            }
            setState(() => _isViewingCart = true);
            _searchController.clear();
            _onSearchChanged('');
            _searchFocusNode.unfocus();
          },
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.elevatedCard,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: product.imageUrl != null
                ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(Icons.image, color: context.colors.textSecondary))
                : Icon(Icons.image, color: context.colors.textSecondary),
          ),
          title: Text(product.name, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
          subtitle: Text(
            '₹${product.sellingPrice.toStringAsFixed(2)} • ${product.quantity > Decimal.zero ? '${product.quantity} in stock' : 'Out of stock'}', 
            style: AppTextStyles.labelSm.copyWith(
              color: product.quantity > Decimal.zero ? context.colors.textSecondary : context.colors.danger
            )
          ),
          trailing: const Icon(Icons.add_shopping_cart),
        );
      },
    );
  }

  Widget _buildProductCatalog() {
    final productsState = ref.watch(productsProvider);
    final products = productsState.products;

    return products.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colors.danger),
            const SizedBox(height: 16),
            Text('Could not load products', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(productsProvider.notifier).fetchProducts(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (productList) {
        if (productList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: context.colors.textTertiary),
                const SizedBox(height: 16),
                Text('No products yet', style: AppTextStyles.titleMd.copyWith(color: context.colors.textSecondary)),
                const SizedBox(height: 8),
                Text('Add products from the Products tab first', style: AppTextStyles.bodySm.copyWith(color: context.colors.textTertiary)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addManualItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Manual Item'),
                ),
              ],
            ),
          );
        }

        // Show product grid
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 80), // bottom padding for FAB
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.78,
          ),
          itemCount: productList.length,
          itemBuilder: (context, index) {
            final product = productList[index];
            final isOutOfStock = product.quantity <= Decimal.zero;

            return GestureDetector(
              onTap: () {
                ref.read(cartProvider.notifier).addProduct(product);
                if (isOutOfStock) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Warning: product is out of stock'), behavior: SnackBarBehavior.floating),
                  );
                }
                setState(() => _isViewingCart = true);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOutOfStock 
                        ? context.colors.danger.withValues(alpha: 0.3) 
                        : context.colors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product image area
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.elevatedCard,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!.startsWith('http') 
                                    ? product.imageUrl! 
                                    : product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(Icons.inventory_2, size: 28, color: context.colors.textTertiary),
                                ),
                              )
                            : Center(
                                child: Icon(Icons.inventory_2, size: 28, color: context.colors.textTertiary),
                              ),
                      ),
                    ),
                    // Product info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${product.sellingPrice.toStringAsFixed(0)}',
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isOutOfStock ? 'Out of stock' : '${product.quantity} in stock',
                              style: AppTextStyles.labelSm.copyWith(
                                color: isOutOfStock ? context.colors.danger : context.colors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartList(CartState cartState) {

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: cartState.items.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.border),
      itemBuilder: (context, index) {
        final item = cartState.items[index];
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: context.colors.elevatedCard,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: item.isManual
                    ? Icon(Icons.edit_note, color: context.colors.primary)
                    : (item.product?.imageUrl != null
                        ? Image.network(item.product!.imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(Icons.image, color: context.colors.textSecondary))
                        : Icon(Icons.image, color: context.colors.textSecondary)),
              ),
              const SizedBox(width: 12),
              
              // Name & Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.effectiveName, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('₹${item.effectivePrice.toStringAsFixed(2)}', style: AppTextStyles.labelSm.copyWith(color: context.colors.textSecondary)),
                  ],
                ),
              ),
              
              // Quantity Stepper
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(item.quantity > Decimal.one ? Icons.remove : Icons.delete_outline, size: 18, color: item.quantity > Decimal.one ? context.colors.textPrimary : context.colors.danger),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36),
                      onPressed: () => ref.read(cartProvider.notifier).updateQuantity(index, item.quantity - Decimal.one),
                    ),
                    GestureDetector(
                      onTap: () => _showEditQuantityDialog(index, item.quantity),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        child: Text('${item.quantity}', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 18, color: context.colors.textPrimary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36),
                      onPressed: () {
                        if (item.product != null && item.quantity + Decimal.one > item.product!.quantity) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Only ${item.product!.quantity} units available'),
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                        ref.read(cartProvider.notifier).updateQuantity(index, item.quantity + Decimal.one);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Subtotal
              SizedBox(
                width: 60,
                child: Text('₹${item.total.toStringAsFixed(0)}', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinnedSummary(CartState cartState, CustomerModel? currentCustomer) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Row
              InkWell(
                onTap: _selectCustomerDialog,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: context.colors.textSecondary),
                          const SizedBox(width: 8),
                          Text(currentCustomer?.name ?? 'Walk-in Customer', style: AppTextStyles.bodyMd.copyWith(color: context.colors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Icon(Icons.chevron_right, size: 18, color: context.colors.textSecondary),
                    ],
                  ),
                ),
              ),
              const Divider(height: 16),
              
              // Summary Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('${cartState.totalItems} Items', style: AppTextStyles.labelMd.copyWith(color: context.colors.textSecondary)),
                      if (!_isViewingCart) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.keyboard_arrow_up, size: 16, color: context.colors.textSecondary),
                      ],
                    ],
                  ),
                  Text('₹${cartState.totalAmount.toDouble().toStringAsFixed(2)}', style: AppTextStyles.labelMd.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Payment Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['cash', 'upi', 'card', 'credit'].map((method) {
                    final isSelected = _selectedPaymentMethod == method;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(method.toUpperCase(), style: TextStyle(color: isSelected ? Colors.white : context.colors.textPrimary)),
                        selected: isSelected,
                        selectedColor: context.colors.primary,
                        backgroundColor: context.colors.background,
                        onSelected: (val) {
                          if (val) setState(() => _selectedPaymentMethod = method);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Checkout Button
              ElevatedButton(
                onPressed: _isCheckoutLoading ? null : _processCheckout,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isCheckoutLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Complete Sale • ₹${cartState.totalAmount.toDouble().toStringAsFixed(2)}', style: AppTextStyles.titleMd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityInputDialog extends StatefulWidget {
  final String initialValue;

  const _QuantityInputDialog({required this.initialValue});

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Quantity'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
