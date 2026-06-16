import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';
import 'package:storemate/features/sales/utils/invoice_template_service.dart';

class InvoiceDetailsScreen extends ConsumerWidget {
  final String saleId;

  const InvoiceDetailsScreen({super.key, required this.saleId});

  Future<void> _shareInvoice(ShopModel shop, SaleModel sale) async {
    final pdfBytes = await ClassicInvoiceTemplate().generateInvoice(shop, sale);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${sale.invoiceNumber}.pdf');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Invoice from ${shop.name}');
  }

  Future<void> _printInvoice(ShopModel shop, SaleModel sale) async {
    final pdfBytes = await ClassicInvoiceTemplate().generateInvoice(shop, sale);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesHistoryProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          salesAsync.when(
            data: (sales) {
              final sale = sales.firstWhere((s) => s.id == saleId);
              final shop = authState.shop!;
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: () => _printInvoice(shop, sale),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareInvoice(shop, sale),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: salesAsync.when(
        data: (sales) {
          final sale = sales.firstWhere(
            (s) => s.id == saleId,
            orElse: () => throw Exception('Sale not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(sale.shopNameSnapshot ?? 'StoreMate Shop', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      if (sale.shopAddressSnapshot != null) Text(sale.shopAddressSnapshot!),
                      if (sale.shopPhoneSnapshot != null) Text('Phone: ${sale.shopPhoneSnapshot!}'),
                      const SizedBox(height: 16),
                      Text('INVOICE', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 2)),
                    ],
                  ),
                ),
                const Divider(height: 32),
                
                // Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invoice No: ${sale.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Date: ${DateFormat.yMd().add_jm().format(sale.createdAt ?? DateTime.now())}'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Customer:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(sale.customer?.name ?? 'Walk-in'),
                        if (sale.customer?.mobileNumber != null) Text(sale.customer!.mobileNumber!),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Items Table
                const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 8),
                ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item.productName)),
                      Expanded(flex: 1, child: Text('${item.quantity}', textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text(item.unitPrice.toStringAsFixed(2), textAlign: TextAlign.right)),
                      Expanded(flex: 1, child: Text(item.subtotal.toStringAsFixed(2), textAlign: TextAlign.right)),
                    ],
                  ),
                )),
                const Divider(height: 32),

                // Totals
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total Amount: ₹${sale.totalAmount.toStringAsFixed(2)}'),
                        if (sale.discountAmount > 0) Text('Discount: -₹${sale.discountAmount.toStringAsFixed(2)}'),
                        if (sale.taxAmount > 0) Text('Tax: +₹${sale.taxAmount.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        Text('Net Amount: ₹${sale.netAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Amount Paid: ₹${sale.amountPaid.toStringAsFixed(2)}'),
                        if (sale.amountDue > 0)
                          Text('Amount Due: ₹${sale.amountDue.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                Center(child: const Text('Thank you for your business!')),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
