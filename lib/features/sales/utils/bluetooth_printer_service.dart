import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bluetoothPrinterServiceProvider = Provider<BluetoothPrinterService>((ref) {
  return BluetoothPrinterService();
});

class BluetoothPrinterService {
  static const String _savedPrinterIdKey = 'saved_printer_id';
  
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<void> savePrinterId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedPrinterIdKey, deviceId);
  }

  Future<String?> getSavedPrinterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedPrinterIdKey);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(license: License.nonprofit, autoConnect: false);
      _connectedDevice = device;
      
      // Discover services to find the write characteristic
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            _writeCharacteristic = characteristic;
            break;
          }
        }
        if (_writeCharacteristic != null) break;
      }

      if (_writeCharacteristic == null) {
        throw Exception("Could not find write characteristic for this printer.");
      }
      
      await savePrinterId(device.remoteId.str);
    } catch (e) {
      _connectedDevice = null;
      _writeCharacteristic = null;
      throw Exception('Failed to connect: $e');
    }
  }

  Future<void> autoConnect() async {
    final savedId = await getSavedPrinterId();
    if (savedId == null) return;
    
    // Check system devices first (already bonded)
    List<BluetoothDevice> systemDevices = await FlutterBluePlus.systemDevices([]);
    for (var device in systemDevices) {
      if (device.remoteId.str == savedId) {
        await connectToDevice(device);
        return;
      }
    }
    
    // Fallback: start a short scan if not in system devices
    try {
      bool found = false;
      var subscription = FlutterBluePlus.onScanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.remoteId.str == savedId) {
            found = true;
            FlutterBluePlus.stopScan();
            connectToDevice(r.device);
            break;
          }
        }
      });
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      await Future.delayed(const Duration(seconds: 5));
      subscription.cancel();
      if (!found) {
         // Device not found
      }
    } catch (e) {
      // Ignored during auto-connect
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _writeCharacteristic = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedPrinterIdKey);
    }
  }

  Future<bool> printReceipt(List<int> bytes) async {
    if (_connectedDevice == null || _writeCharacteristic == null) {
      // Attempt auto-connect if we have a saved device
      await autoConnect();
      if (_connectedDevice == null || _writeCharacteristic == null) {
        throw Exception("No printer connected");
      }
    }

    try {
      // Android bluetooth might drop large chunks, so we chunk it just in case
      // standard MTU is around 20-512, ESC/POS can usually take larger chunks 
      // but let's be safe with chunk size of 100 bytes
      const int chunkSize = 100;
      for (var i = 0; i < bytes.length; i += chunkSize) {
        var end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        var chunk = bytes.sublist(i, end);
        await _writeCharacteristic!.write(chunk, withoutResponse: _writeCharacteristic!.properties.writeWithoutResponse);
        // Small delay to prevent buffer overflow on cheap printers
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return true;
    } catch (e) {
      throw Exception('Failed to print: $e');
    }
  }
}
