import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/product/data/models/product_model.dart';
import 'package:storemate/features/product/data/repositories/product_repository.dart';

class ProductsState {
  final AsyncValue<List<ProductModel>> products;
  final bool hasMore;
  final int page;
  final String? searchQuery;
  final String? categoryId;

  ProductsState({
    required this.products,
    this.hasMore = true,
    this.page = 1,
    this.searchQuery,
    this.categoryId,
  });

  ProductsState copyWith({
    AsyncValue<List<ProductModel>>? products,
    bool? hasMore,
    int? page,
    String? searchQuery,
    String? categoryId,
    bool clearCategory = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    );
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier(ref.read(productRepositoryProvider));
});

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository _repository;
  static const int _limit = 20;

  ProductsNotifier(this._repository)
      : super(ProductsState(products: const AsyncValue.loading())) {
    fetchProducts(refresh: true);
  }

  Future<void> fetchProducts({bool refresh = false, String? search}) async {
    if (search != null) {
      state = state.copyWith(searchQuery: search);
    }
    
    if (refresh) {
      state = state.copyWith(page: 1, hasMore: true, products: const AsyncValue.loading());
    } else if (!state.hasMore || state.products.isLoading) {
      return;
    }

    try {
      final result = await _repository.getProducts(
        page: state.page,
        limit: _limit,
        search: state.searchQuery,
        categoryId: state.categoryId,
      );

      final newItems = result['items'] as List<ProductModel>;
      final meta = result['meta'] as Map<String, dynamic>;
      
      final currentList = state.products.value ?? [];
      final updatedList = refresh ? newItems : [...currentList, ...newItems];
      
      state = state.copyWith(
        products: AsyncValue.data(updatedList),
        hasMore: state.page < meta['totalPages'],
        page: state.page + 1,
      );
    } catch (e, st) {
      if (refresh) {
        state = state.copyWith(products: AsyncValue.error(e, st));
      } else {
        // If it fails on pagination, don't overwrite the whole list with error.
        // In a real app we'd handle pagination errors gracefully.
      }
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchProducts(refresh: true);
  }

  void setCategoryFilter(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearCategory: categoryId == null);
    fetchProducts(refresh: true);
  }

  Future<ProductModel> addProduct(Map<String, dynamic> data) async {
    final newProduct = await _repository.createProduct(data);
    // Refresh the list to reflect new product and sorting
    fetchProducts(refresh: true);
    return newProduct;
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final updatedProduct = await _repository.updateProduct(id, data);
    
    // Optimistic update of the list
    state = state.copyWith(
      products: state.products.whenData((list) {
        return list.map((p) => p.id == id ? updatedProduct : p).toList();
      }),
    );
    
    return updatedProduct;
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    state = state.copyWith(
      products: state.products.whenData((list) {
        return list.where((p) => p.id != id).toList();
      }),
    );
  }
}
