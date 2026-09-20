import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/core/widgets/app_card.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import '../providers/staff_provider.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Staff Management'),
      ),
      body: staffAsync.when(
        data: (staffList) {
          if (staffList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: AppEmptyState(
                icon: Icons.badge_outlined,
                title: 'No staff members found',
                explanation: 'Add cashiers and managers to help run your shop.',
                actionLabel: 'Add Staff',
                onAction: () => context.pushNamed('staff-add'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(staffListProvider.future),
            color: context.colors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: staffList.length,
              separatorBuilder: (a, b) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return _StaffListItem(staff: staff);
              },
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: AppEmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load staff',
            explanation: error.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.refresh(staffListProvider.future),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.push('/staff/add'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.primaryForeground,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StaffListItem extends ConsumerWidget {
  final UserModel staff;

  const _StaffListItem({required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(staff.name ?? staff.mobileNumber, style: AppTextStyles.bodyLg.copyWith(color: context.colors.textPrimary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Role: ${staff.role.toUpperCase()}', style: AppTextStyles.labelMd.copyWith(color: context.colors.textSecondary)),
            Text('Phone: ${staff.mobileNumber}', style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)),
            const SizedBox(height: 4),
            if (staff.isInvited == true)
              Text('Status: Invited', style: AppTextStyles.labelSm.copyWith(color: context.colors.warning))
            else if (staff.isActive == false)
              Text('Status: Deactivated', style: AppTextStyles.labelSm.copyWith(color: context.colors.danger))
            else
              Text('Last Login: ${staff.lastLoginAt != null ? staff.lastLoginAt.toString().split('.')[0] : 'Never'}', style: AppTextStyles.labelSm.copyWith(color: context.colors.success)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: context.colors.primary),
          onPressed: () => context.pushNamed('staff-edit', extra: staff),
        ),
      ),
    );
  }
}
