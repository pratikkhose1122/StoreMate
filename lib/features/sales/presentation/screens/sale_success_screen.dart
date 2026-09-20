import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/auth/presentation/providers/auth_provider.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';
import 'package:storemate/features/sales/utils/bill_sharing_service.dart';
import 'package:storemate/features/sales/presentation/widgets/share_bill_dialog.dart';
import 'package:storemate/core/providers/core_providers.dart';

class SaleSuccessScreen extends ConsumerStatefulWidget {
  final String saleId;
  const SaleSuccessScreen({super.key, required this.saleId});

  @override
  ConsumerState<SaleSuccessScreen> createState() => _SaleSuccessScreenState();
}

class _SaleSuccessScreenState extends ConsumerState<SaleSuccessScreen> {
  late final BillSharingService _billSharingService;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _billSharingService = BillSharingService(ref.read(dioClientProvider));
  }

  Future<void> _handleShareBill(BuildContext context, dynamic sale, dynamic shop) async {
    final phoneNumber = await showDialog<String>(
      context: context,
      builder: (context) => ShareBillDialog(
        initialPhoneNumber: sale.customer?.mobileNumber,
      ),
    );

    if (phoneNumber != null && context.mounted) {
      await _billSharingService.shareBill(context, sale, shop, phoneNumber: phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saleAsync = ref.watch(saleDetailsProvider(widget.saleId));

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: saleAsync.when(
          data: (sale) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.check_circle, size: 80, color: context.colors.success),
                const SizedBox(height: 16),
                Text('Sale Completed', style: AppTextStyles.displaySm.copyWith(color: context.colors.textPrimary), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Invoice #${sale.invoiceNumber}', style: AppTextStyles.bodyLg.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
                Text('₹${sale.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.displayMd.copyWith(color: context.colors.textPrimary), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer', style: AppTextStyles.labelSm.copyWith(color: context.colors.textSecondary)),
                          Text(sale.customer?.name ?? 'Walk-in', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Payment', style: AppTextStyles.labelSm.copyWith(color: context.colors.textSecondary)),
                          Text(sale.payments.isNotEmpty ? sale.payments.first.paymentMethod.toUpperCase() : 'CASH', style: AppTextStyles.bodyMd.copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('New Sale'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/sales/${sale.id}'),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('View Invoice'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _handleShareBill(context, sale, ref.read(authProvider).shop!),
                  icon: const Icon(Icons.share),
                  label: const Text('Share Bill'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green, // Differentiating share CTA
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading sale: $e', style: TextStyle(color: context.colors.danger))),
        ),
      ),
    );
  }
}
