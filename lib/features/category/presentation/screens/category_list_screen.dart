import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/category/presentation/providers/categories_provider.dart';
import 'package:storemate/core/widgets/app_card.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.push('/categories/add'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.primaryForeground,
        child: const Icon(Icons.add),
      ),
      body: categoriesState.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: AppEmptyState(
                icon: Icons.category_outlined,
                title: 'No categories found',
                explanation: 'Create product categories to organize your inventory.',
                actionLabel: 'Add Category',
                onAction: () => context.push('/categories/add'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(categoriesProvider.notifier).fetchCategories(),
            color: context.colors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (a, b) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                return AppCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(category.name, style: AppTextStyles.bodyLg.copyWith(color: context.colors.textPrimary)),
                    subtitle: category.description != null 
                        ? Text(category.description!, style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)) 
                        : null,
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: context.colors.primary),
                      onPressed: () => context.push('/categories/edit', extra: category),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load categories',
            explanation: err.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.read(categoriesProvider.notifier).fetchCategories(),
          ),
        ),
      ),
    );
  }
}
