import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/features/auth/data/models/user_model.dart';
import '../providers/staff_provider.dart';

class AddEditStaffScreen extends ConsumerStatefulWidget {
  final UserModel? staff;

  const AddEditStaffScreen({super.key, this.staff});

  @override
  ConsumerState<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends ConsumerState<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  String _selectedRole = 'cashier';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff?.name ?? '');
    _mobileController = TextEditingController(text: widget.staff?.mobileNumber ?? '');
    _selectedRole = widget.staff?.role ?? 'cashier';
    _isActive = widget.staff?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(staffNotifierProvider.notifier);

    if (widget.staff == null) {
      // Invite new
      await notifier.inviteStaff(
        name: _nameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        role: _selectedRole,
      );
    } else {
      // Edit existing
      await notifier.updateStaff(
        id: widget.staff!.id,
        role: _selectedRole,
        isActive: _isActive,
      );
    }

    final state = ref.read(staffNotifierProvider);
    if (!state.hasError) {
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.staff == null ? 'Staff invited successfully' : 'Staff updated successfully')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.staff != null;
    final isLoading = ref.watch(staffNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Staff' : 'Invite Staff'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Staff Name'),
                enabled: !isEditing,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                enabled: !isEditing, // Only allow setting phone on invite
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRole = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (isEditing)
                SwitchListTile(
                  title: const Text('Is Active (Can Login)'),
                  value: _isActive,
                  onChanged: (val) {
                    setState(() => _isActive = val);
                  },
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? 'Update Staff' : 'Send Invite'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
