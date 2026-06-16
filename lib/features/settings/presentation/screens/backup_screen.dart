import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  Future<void> _exportData(BuildContext context, String type) async {
    try {
      // Call backend to stream CSV
      // e.g. final bytes = await dio.get('/reports/export/$type', options: Options(responseType: ResponseType.bytes));
      // Save locally using path_provider
      // Share using share_plus
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exporting $type...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backups & Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Keep your data safe. Export your shop data as CSV files which can be opened in Excel.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildExportTile(
            context,
            title: 'Products Inventory',
            icon: Icons.inventory_2,
            type: 'products',
          ),
          _buildExportTile(
            context,
            title: 'Customer Database',
            icon: Icons.people,
            type: 'customers',
          ),
          _buildExportTile(
            context,
            title: 'Sales History',
            icon: Icons.receipt_long,
            type: 'sales',
          ),
          _buildExportTile(
            context,
            title: 'Inventory Logs',
            icon: Icons.history,
            type: 'inventory-logs',
          ),
        ],
      ),
    );
  }

  Widget _buildExportTile(BuildContext context, {required String title, required IconData icon, required String type}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.download),
        onTap: () => _exportData(context, type),
      ),
    );
  }
}
