import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/category/presentation/providers/categories_provider.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/categories/add'),
        child: const Icon(Icons.add),
      ),
      body: categoriesState.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(categoriesProvider.notifier).fetchCategories(),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.name, style: AppTextStyles.bodyLarge),
                  subtitle: category.description != null ? Text(category.description!) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () => context.push('/categories/edit', extra: category),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load categories', style: AppTextStyles.bodyLarge),
              TextButton(
                onPressed: () => ref.read(categoriesProvider.notifier).fetchCategories(),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
