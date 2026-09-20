import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/sales/data/models/sale_model.dart';
import 'package:storemate/features/sales/presentation/providers/refund_provider.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';
import 'package:storemate/features/sales/utils/refund_receipt_service.dart';
import 'package:printing/printing.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:decimal/decimal.dart';

class RefundScreen extends ConsumerStatefulWidget {
  final String saleId;

  const RefundScreen({super.key, required this.saleId});

  @override
  ConsumerState<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends ConsumerState<RefundScreen> {
  final Map<String, Decimal> _refundQuantities = {};
  String? _selectedReason;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Damaged',
    'Expired',
    'Wrong Item',
    'Customer Changed Mind',
    'Billing Error',
    'Other'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitRefund(SaleModel sale) async {
    final itemsToRefund = <Map<String, dynamic>>[];

    for (final item in sale.items) {
      final qty = _refundQuantities[item.id] ?? Decimal.zero;
      if (qty > Decimal.zero) {
        // Calculate proportionate values
        final unitPrice = item.unitPrice;
        final taxAmount = ((item.taxPercentage / Decimal.fromInt(100)) * unitPrice.toRational() * qty.toRational()).toDecimal(scaleOnInfinitePrecision: 2); // approximation if tax was per unit
        // Since original taxAmount wasn't stored per unit, we approximate based on unitPrice and taxPercentage
        // Wait, SaleItemModel has subtotal. Let's recalculate accurately based on current unitPrice
        final lineTotal = unitPrice * qty;
        itemsToRefund.add({
          'sale_item_id': item.id,
          'product_id': item.productId,
          'quantity': qty.toString(),
        });
      }
    }

    if (itemsToRefund.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one item to refund.')));
      return;
    }

    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a reason.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final originalPaymentMethod = sale.payments.isNotEmpty ? sale.payments.first.paymentMethod : 'unknown';
      // In a real app, you might ask the user how they are refunding. Here we default to cash.
      final refundPaymentMethod = 'cash'; 

      final returnId = await ref.read(refundRepositoryProvider).processRefund(
        saleId: widget.saleId,
        originalPaymentMethod: originalPaymentMethod,
        refundPaymentMethod: refundPaymentMethod,
        reason: _selectedReason!,
        notes: _notesController.text.trim(),
        items: itemsToRefund,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refund processed successfully!')));
        // Invalidate sales provider so history updates
        ref.invalidate(salesHistoryProvider);
        ref.invalidate(saleDetailsProvider(widget.saleId));
        ref.invalidate(returnsForSaleProvider(widget.saleId));
        
        // Generate and share PDF
        final authState = ref.read(authProvider);
        if (authState.shop != null) {
          try {
            // Fetch the newly created return record
            final repository = ref.read(refundRepositoryProvider);
            final returns = await repository.getReturnsForSale(widget.saleId);
            final returnRecord = returns.firstWhere((r) => r.id == returnId);
            
            final pdfBytes = await RefundReceiptService().generateRefundReceipt(authState.shop!, sale, returnRecord);
            await Printing.sharePdf(
              bytes: pdfBytes, 
              filename: 'StoreMate_Refund_${returnRecord.refundNumber}.pdf',
            );
          } catch (e) {
            debugPrint('Failed to generate receipt: $e');
          }
        }
        
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saleAsync = ref.watch(saleDetailsProvider(widget.saleId));
    final returnsAsync = ref.watch(returnsForSaleProvider(widget.saleId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('Process Refund')),
      body: saleAsync.when(
        data: (sale) {
          return returnsAsync.when(
            data: (returns) {
              // Calculate already refunded map
              final refundedMap = <String, Decimal>{};
              for (final ret in returns) {
                for (final item in ret.items) {
                  refundedMap[item.saleItemId] = (refundedMap[item.saleItemId] ?? Decimal.zero) + item.quantity;
                }
              }

              Decimal totalRefundAmount = Decimal.zero;
              for (final item in sale.items) {
                final qty = _refundQuantities[item.id] ?? Decimal.zero;
                totalRefundAmount += item.unitPrice * qty; // Simplified total
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Items to Refund', style: AppTextStyles.titleMd.copyWith(color: context.colors.textPrimary)),
                          const SizedBox(height: 16),
                          ...sale.items.map((item) {
                            final alreadyRefunded = refundedMap[item.id] ?? Decimal.zero;
                            final refundableQty = item.quantity - alreadyRefunded;
                            final selectedQty = _refundQuantities[item.id] ?? Decimal.zero;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.colors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.colors.border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.productName, style: AppTextStyles.bodyLg.copyWith(color: context.colors.textPrimary)),
                                        const SizedBox(height: 4),
                                        Text('₹${item.unitPrice.toDouble().toStringAsFixed(2)} / unit', style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)),
                                        if (alreadyRefunded > Decimal.zero)
                                          Text('Already Refunded: $alreadyRefunded', style: AppTextStyles.labelSm.copyWith(color: context.colors.danger)),
                                      ],
                                    ),
                                  ),
                                  if (refundableQty == Decimal.zero)
                                    Text('Fully Refunded', style: AppTextStyles.labelMd.copyWith(color: context.colors.textSecondary))
                                  else
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: selectedQty > Decimal.zero ? () {
                                            setState(() => _refundQuantities[item.id] = selectedQty - Decimal.one);
                                          } : null,
                                        ),
                                        Text('$selectedQty', style: AppTextStyles.titleMd.copyWith(color: context.colors.textPrimary)),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: selectedQty < refundableQty ? () {
                                            setState(() => _refundQuantities[item.id] = selectedQty + Decimal.one);
                                          } : null,
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            );
                          }),
                          
                          const SizedBox(height: 24),
                          Text('Reason for Refund', style: AppTextStyles.titleMd.copyWith(color: context.colors.textPrimary)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _reasons.map((r) => ChoiceChip(
                              label: Text(r),
                              selected: _selectedReason == r,
                              onSelected: (val) {
                                if (val) setState(() => _selectedReason = r);
                              },
                            )).toList(),
                          ),
                          if (_selectedReason == 'Other') ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Enter reason',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Bar
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      border: Border(top: BorderSide(color: context.colors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Refund Total', style: AppTextStyles.labelSm.copyWith(color: context.colors.textSecondary)),
                            Text('₹${totalRefundAmount.toDouble().toStringAsFixed(2)}', style: AppTextStyles.titleLg.copyWith(color: context.colors.primary)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _isSubmitting || totalRefundAmount == Decimal.zero ? null : () => _submitRefund(sale),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            backgroundColor: context.colors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Refund'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading returns: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading sale: $e')),
      ),
    );
  }
}
