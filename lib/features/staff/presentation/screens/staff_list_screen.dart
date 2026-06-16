import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import '../providers/staff_provider.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed('staff-add'),
          ),
        ],
      ),
      body: staffAsync.when(
        data: (staffList) {
          if (staffList.isEmpty) {
            return const Center(child: Text('No staff members found.'));
          }
          return ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return _StaffListItem(staff: staff);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StaffListItem extends ConsumerWidget {
  final UserModel staff;

  const _StaffListItem({required this.staff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(staff.name ?? staff.mobileNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${staff.role.toUpperCase()}'),
            Text('Phone: ${staff.mobileNumber}'),
            if (staff.isInvited == true)
              const Text('Status: Invited', style: TextStyle(color: Colors.orange))
            else if (staff.isActive == false)
              const Text('Status: Deactivated', style: TextStyle(color: Colors.red))
            else
              Text('Last Login: ${staff.lastLoginAt != null ? staff.lastLoginAt.toString().split('.')[0] : 'Never'}', style: const TextStyle(color: Colors.green)),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => context.pushNamed('staff-edit', extra: staff),
        ),
      ),
    );
  }
}
