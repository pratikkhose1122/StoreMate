import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/sales/utils/bluetooth_printer_service.dart';
import 'package:storemate/features/sales/utils/thermal_receipt_service.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  PaperSize _paperSize = PaperSize.mm80;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkPermissionsAndScan();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getString('paper_size');
    if (size == '58mm') {
      setState(() => _paperSize = PaperSize.mm58);
    }
  }

  Future<void> _savePaperSize(PaperSize size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('paper_size', size == PaperSize.mm80 ? '80mm' : '58mm');
    setState(() => _paperSize = size);
  }

  Future<void> _checkPermissionsAndScan() async {
    if (await FlutterBluePlus.isSupported == false) {
      return;
    }
    
    // Listen to scan results
    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (mounted) {
          setState(() {
            _scanResults = results;
          });
        }
      },
      onError: (e) => print(e),
    );

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    _startScan();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    final printerService = ref.read(bluetoothPrinterServiceProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      await printerService.connectToDevice(device);
      if (mounted) {
        Navigator.pop(context); // hide dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${device.platformName.isEmpty ? 'Printer' : device.platformName}')),
        );
        setState(() {}); // refresh UI to show connected status
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  Future<void> _testPrint() async {
    final printerService = ref.read(bluetoothPrinterServiceProvider);
    final receiptService = ref.read(thermalReceiptServiceProvider);
    
    if (printerService.connectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No printer connected!')),
      );
      return;
    }

    try {
      final bytes = await receiptService.generateTestReceipt(_paperSize);
      await printerService.printReceipt(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test print failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final printerService = ref.watch(bluetoothPrinterServiceProvider);
    final connectedDevice = printerService.connectedDevice;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Printer Settings'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? () => FlutterBluePlus.stopScan() : _startScan,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Configuration', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                RadioListTile<PaperSize>(
                  title: Text('80mm Receipt (Standard)', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                  value: PaperSize.mm80,
                  groupValue: _paperSize,
                  onChanged: (size) => _savePaperSize(size!),
                  activeColor: context.colors.primary,
                ),
                Divider(color: context.colors.border, height: 1),
                RadioListTile<PaperSize>(
                  title: Text('58mm Receipt (Small)', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                  value: PaperSize.mm58,
                  groupValue: _paperSize,
                  onChanged: (size) => _savePaperSize(size!),
                  activeColor: context.colors.primary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text('Connected Printer', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
          const SizedBox(height: 12),
          if (connectedDevice != null) ...[
            Container(
              decoration: BoxDecoration(
                color: context.colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.success),
              ),
              child: ListTile(
                leading: Icon(Icons.print, color: context.colors.success),
                title: Text(connectedDevice.platformName.isEmpty ? 'Unknown Printer' : connectedDevice.platformName, 
                  style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                subtitle: Text(connectedDevice.remoteId.str, style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: _testPrint,
                      child: Text('Test', style: TextStyle(color: context.colors.primary)),
                    ),
                    IconButton(
                      icon: Icon(Icons.link_off, color: context.colors.danger),
                      onPressed: () async {
                        await printerService.disconnect();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Center(
                child: Text('No printer connected', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
            ),
          ],

          const SizedBox(height: 24),
          
          Text('Available Devices', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
          const SizedBox(height: 12),
          
          if (_scanResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _isScanning ? 'Scanning for printers...' : 'No Bluetooth devices found. Please ensure Bluetooth is enabled.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary),
                ),
              ),
            )
          else
            ..._scanResults.map((r) {
              // Hide already connected device from available list
              if (connectedDevice != null && r.device.remoteId == connectedDevice.remoteId) {
                return const SizedBox.shrink();
              }
              
              final deviceName = r.device.platformName.isNotEmpty ? r.device.platformName : 'Unknown Device';
              return Card(
                color: context.colors.card,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.bluetooth, color: context.colors.textSecondary),
                  title: Text(deviceName, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                  subtitle: Text(r.device.remoteId.str, style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.primaryForeground,
                    ),
                    onPressed: () => _connectToPrinter(r.device),
                    child: const Text('Connect'),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
