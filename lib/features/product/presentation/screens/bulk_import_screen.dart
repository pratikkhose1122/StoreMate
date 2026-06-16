import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:storemate/features/product/data/repositories/product_repository.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/shared/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';

class BulkImportScreen extends ConsumerStatefulWidget {
  const BulkImportScreen({super.key});

  @override
  ConsumerState<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends ConsumerState<BulkImportScreen> {
  bool _isLoading = false;
  String? _selectedFilePath;
  
  Map<String, dynamic>? _previewData;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _previewData = null; // reset previous
      });
      await _uploadForPreview();
    }
  }

  Future<void> _uploadForPreview() async {
    if (_selectedFilePath == null) return;
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final preview = await repo.previewBulkImport(_selectedFilePath!);
      setState(() {
        _previewData = preview;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmImport() async {
    if (_selectedFilePath == null) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final result = await repo.confirmBulkImport(_selectedFilePath!);
      
      ref.read(productsProvider.notifier).fetchProducts(refresh: true);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Import Complete'),
            content: Text('Successfully imported ${result['imported']} products.\nFailed: ${result['failed']}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Import Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Upload a CSV file to import multiple products at once.', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFile,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Select CSV File'),
                    ),
                    if (_selectedFilePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Selected: ${_selectedFilePath!.split(RegExp(r'[/\\]')).last}'),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (_isLoading && _previewData == null)
              const Center(child: CircularProgressIndicator())
            else if (_previewData != null)
              Expanded(
                child: _buildPreview(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final validRows = _previewData!['validRows'] as List;
    final invalidRows = _previewData!['invalidRows'] as List;
    final warnings = _previewData!['warnings'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Preview Report', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Valid', validRows.length, Colors.green),
            _buildStatCard('Invalid', invalidRows.length, Colors.red),
            _buildStatCard('Warnings', warnings.length, Colors.orange),
          ],
        ),
        
        const SizedBox(height: 16),
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Valid'),
                    Tab(text: 'Errors'),
                    Tab(text: 'Warnings'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildList(validRows, (row) => ListTile(
                        title: Text(row['name']),
                        subtitle: Text('SKU: ${row['sku'] ?? 'N/A'} | Price: ₹${row['sellingPrice']} | Qty: ${row['quantity']}'),
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                      )),
                      _buildList(invalidRows, (row) => ListTile(
                        title: Text('Row ${row['rowNum']}: ${row['row']['name'] ?? 'Unknown'}'),
                        subtitle: Text((row['errors'] as List).join(', '), style: const TextStyle(color: Colors.red)),
                        leading: const Icon(Icons.error, color: Colors.red),
                      )),
                      _buildList(warnings, (w) => ListTile(
                        title: Text(w.toString()),
                        leading: const Icon(Icons.warning, color: Colors.orange),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        CustomButton(
          text: 'Confirm Import (${validRows.length} products)',
          isLoading: _isLoading,
          onPressed: validRows.isEmpty ? null : _confirmImport,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List items, Widget Function(dynamic) itemBuilder) {
    if (items.isEmpty) return const Center(child: Text('None'));
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) => itemBuilder(items[index]),
    );
  }
}
