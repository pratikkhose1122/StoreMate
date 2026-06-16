import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/features/category/data/models/category_model.dart';
import 'package:storemate/features/category/data/repositories/category_repository.dart';

// Provider that fetches and caches the list of categories.
// We use an AsyncValue for loading/error states.
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>(
  (ref) => CategoriesNotifier(ref.read(categoryRepositoryProvider)),
);

class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoryRepository _repository;

  CategoriesNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(String name, String? description) async {
    try {
      final newCategory = await _repository.createCategory(name, description);
      state = state.whenData((categories) => [...categories, newCategory]..sort((a, b) => a.name.compareTo(b.name)));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(String id, String name, String? description) async {
    try {
      final updatedCategory = await _repository.updateCategory(id, name, description);
      state = state.whenData((categories) {
        return categories.map((c) => c.id == id ? updatedCategory : c).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      state = state.whenData((categories) => categories.where((c) => c.id != id).toList());
    } catch (e) {
      rethrow;
    }
  }
}
