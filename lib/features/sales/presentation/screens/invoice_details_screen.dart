import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/features/sales/utils/bluetooth_printer_service.dart';
import 'package:storemate/features/sales/utils/thermal_receipt_service.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';
import 'package:storemate/features/shop/data/models/shop_model.dart';
import 'package:storemate/features/sales/utils/invoice_template_service.dart';
import 'package:storemate/features/sales/presentation/providers/cart_provider.dart';
import 'package:storemate/features/product/presentation/providers/products_provider.dart';
import 'package:storemate/features/sales/utils/bill_sharing_service.dart';
import 'package:storemate/features/sales/presentation/widgets/share_bill_dialog.dart';
import 'package:storemate/core/providers/core_providers.dart';
import 'package:go_router/go_router.dart';

class InvoiceDetailsScreen extends ConsumerWidget {
  final String saleId;

  const InvoiceDetailsScreen({super.key, required this.saleId});

  Future<void> _handleShareBill(BuildContext context, WidgetRef ref, ShopModel shop, SaleModel sale) async {
    final phoneNumber = await showDialog<String>(
      context: context,
      builder: (context) => ShareBillDialog(
        initialPhoneNumber: sale.customer?.mobileNumber,
      ),
    );

    if (phoneNumber != null && context.mounted) {
      final billSharingService = BillSharingService(ref.read(dioClientProvider));
      await billSharingService.shareBill(context, sale, shop, phoneNumber: phoneNumber);
    }
  }

  Future<void> _printInvoice(ShopModel shop, SaleModel sale) async {
    final pdfBytes = await ClassicInvoiceTemplate().generateInvoice(shop, sale);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  Future<void> _thermalPrint(BuildContext context, WidgetRef ref, ShopModel shop, SaleModel sale) async {
    final printerService = ref.read(bluetoothPrinterServiceProvider);
    
    if (printerService.connectedDevice == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No printer connected. Please connect in Settings.')),
        );
      }
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final sizeStr = prefs.getString('paper_size');
      final paperSize = sizeStr == '58mm' ? PaperSize.mm58 : PaperSize.mm80;

      final receiptBytes = await ref.read(thermalReceiptServiceProvider).generateReceipt(
        sale,
        paperSize: paperSize,
        shopName: shop.name,
        gstNumber: shop.gstNumber,
      );
      await printerService.printReceipt(receiptBytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleAsync = ref.watch(saleDetailsProvider(saleId));
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          saleAsync.when(
            data: (sale) {
              final shop = authState.shop!;
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.receipt, color: context.colors.textSecondary),
                    tooltip: 'Thermal Print',
                    onPressed: () => _thermalPrint(context, ref, shop, sale),
                  ),
                  IconButton(
                    icon: Icon(Icons.print, color: context.colors.textSecondary),
                    tooltip: 'A4 Print',
                    onPressed: () => _printInvoice(shop, sale),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: context.colors.textSecondary),
                    tooltip: 'Share Bill',
                    onPressed: () => _handleShareBill(context, ref, shop, sale),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(),
            error: (a, b) => const SizedBox(),
          ),
        ],
      ),
      body: saleAsync.when(
        data: (sale) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Text(sale.shopNameSnapshot ?? 'StoreMate Shop', style: AppTextStyles.titleLg.copyWith(color: context.colors.textPrimary)),
                              if (sale.shopAddressSnapshot != null) Text(sale.shopAddressSnapshot!, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary)),
                              if (sale.shopPhoneSnapshot != null) Text('Phone: ${sale.shopPhoneSnapshot!}', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('INVOICE', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary, letterSpacing: 2)),
                                  if (sale.status != 'completed') ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: sale.status == 'fully_refunded' ? context.colors.danger : Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        sale.status.replaceAll('_', ' ').toUpperCase(),
                                        style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 32, color: context.colors.border),
                        
                        // Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Invoice No: ${sale.invoiceNumber}', style: AppTextStyles.labelMd.copyWith(color: context.colors.textPrimary)),
                                Text('Date: ${DateFormat.yMd().add_jm().format(sale.createdAt ?? DateTime.now())}', style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Customer:', style: AppTextStyles.labelMd.copyWith(color: context.colors.textPrimary)),
                                Text(sale.customer?.name ?? 'Walk-in', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                                if (sale.customer?.mobileNumber != null) Text(sale.customer!.mobileNumber!, style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        Divider(height: 32, color: context.colors.border),

                        // Items Table
                        Row(
                          children: [
                            Expanded(flex: 3, child: Text('Item', style: AppTextStyles.labelSm.copyWith(color: context.colors.textPrimary))),
                            Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: AppTextStyles.labelSm.copyWith(color: context.colors.textPrimary))),
                            Expanded(flex: 1, child: Text('Price', textAlign: TextAlign.right, style: AppTextStyles.labelSm.copyWith(color: context.colors.textPrimary))),
                            Expanded(flex: 1, child: Text('Total', textAlign: TextAlign.right, style: AppTextStyles.labelSm.copyWith(color: context.colors.textPrimary))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...sale.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text(item.productName, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary))),
                              Expanded(flex: 1, child: Text('${item.quantity}', textAlign: TextAlign.center, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary))),
                              Expanded(flex: 1, child: Text(CurrencyFormatter.format(item.unitPrice), textAlign: TextAlign.right, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary))),
                              Expanded(flex: 1, child: Text(CurrencyFormatter.format(item.subtotal), textAlign: TextAlign.right, style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary))),
                            ],
                          ),
                        )),
                        Divider(height: 32, color: context.colors.border),

                        // Totals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total Amount: ₹${CurrencyFormatter.format(sale.totalAmount)}', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                                if (sale.discountAmount > Decimal.zero) Text('Discount: -₹${CurrencyFormatter.format(sale.discountAmount)}', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                                if (sale.taxAmount > Decimal.zero) Text('Tax: +₹${CurrencyFormatter.format(sale.taxAmount)}', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                                const SizedBox(height: 8),
                                Text('Net Amount: ₹${CurrencyFormatter.format(sale.netAmount)}', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
                                const SizedBox(height: 8),
                                Text('Amount Paid: ₹${CurrencyFormatter.format(sale.amountPaid)}', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary)),
                                if (sale.amountDue > Decimal.zero)
                                  Text('Amount Due: ₹${CurrencyFormatter.format(sale.amountDue)}', style: AppTextStyles.labelMd.copyWith(color: context.colors.danger)),
                                if ((sale.refundAmount ?? Decimal.zero) > Decimal.zero) ...[
                                  const SizedBox(height: 8),
                                  Text('Refunded: -₹${CurrencyFormatter.format(sale.refundAmount ?? Decimal.zero)}', style: AppTextStyles.labelMd.copyWith(color: context.colors.danger)),
                                  Text('Adjusted Net: ₹${CurrencyFormatter.format(sale.netAmount - (sale.refundAmount ?? Decimal.zero))}', style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
                                ],
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        Center(child: Text('Thank you for your business!', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary, fontStyle: FontStyle.italic))),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  border: Border(top: BorderSide(color: context.colors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share Bill'),
                        onPressed: () {
                          if (authState.shop != null) _handleShareBill(context, ref, authState.shop!, sale);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('Duplicate'),
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          if (sale.customer != null) {
                            ref.read(cartProvider.notifier).setCustomer(sale.customer!.id);
                          }
                          
                          final allProducts = ref.read(productsProvider).products.valueOrNull ?? [];
                          
                          for (var item in sale.items) {
                            if (item.productId == null) {
                              ref.read(cartProvider.notifier).addManualItem(
                                name: item.productName,
                                price: item.unitPrice,
                                quantity: item.quantity,
                                taxPercentage: item.taxPercentage,
                              );
                            } else {
                              final p = allProducts.where((p) => p.id == item.productId).firstOrNull;
                              if (p != null) {
                                ref.read(cartProvider.notifier).addProduct(p, quantity: item.quantity);
                              } else {
                                ref.read(cartProvider.notifier).addManualItem(
                                  name: item.productName,
                                  price: item.unitPrice,
                                  quantity: item.quantity,
                                  taxPercentage: item.taxPercentage,
                                );
                              }
                            }
                          }
                          
                          context.push('/pos');
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale duplicated and loaded to POS.')));
                        },
                      ),
                    ),
                    if ((authState.user?.role == 'owner' || authState.user?.role == 'manager') && sale.status != 'fully_refunded') ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.settings_backup_restore, color: context.colors.danger),
                          label: Text('Refund', style: TextStyle(color: context.colors.danger)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.colors.danger),
                          ),
                          onPressed: () {
                            context.push('/sales/${sale.id}/refund');
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: context.colors.danger))),
      ),
    );
  }
}
