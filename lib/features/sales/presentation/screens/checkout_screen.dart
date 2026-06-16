import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/features/customer/presentation/providers/customers_provider.dart';
import 'package:storemate/features/sales/presentation/providers/cart_provider.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';
import 'package:storemate/shared/widgets/custom_button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'cash';
  bool _isPartialPayment = false;
  late TextEditingController _amountPaidController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountPaidController = TextEditingController();
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      double amountPaid = cartState.totalAmount;
      if (_isPartialPayment) {
        amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
      }

      final payments = [
        {
          'amount': amountPaid,
          'paymentMethod': _selectedPaymentMethod,
        }
      ];

      // If credit, add the remaining amount as a credit payment logically
      final amountDue = cartState.totalAmount - amountPaid;
      if (amountDue > 0 && cartState.customerId != null) {
        payments.add({
          'amount': amountDue,
          'paymentMethod': 'credit',
        });
      } else if (amountDue > 0 && cartState.customerId == null) {
        throw Exception('A customer must be selected for credit / partial payments.');
      }

      final payload = {
        'customerId': cartState.customerId,
        'items': cartState.items.map((i) => {
          'productId': i.product.id,
          'quantity': i.quantity,
          'unitPrice': i.product.sellingPrice,
          'taxPercentage': i.product.taxPercentage,
        }).toList(),
        'totalAmount': cartState.items.fold(0.0, (sum, i) => sum + (i.product.sellingPrice * i.quantity)),
        'discountAmount': cartState.totalDiscount,
        'taxAmount': cartState.totalTax,
        'netAmount': cartState.totalAmount,
        'payments': payments,
      };

      final sale = await ref.read(salesRepositoryProvider).checkout(payload);

      ref.read(cartProvider.notifier).clearCart();
      if (mounted) {
        // Go to success/invoice screen
        context.go('/sales/${sale.id}');
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
    final cartState = ref.watch(cartProvider);
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customer Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    customersAsync.when(
                      data: (customers) {
                        return DropdownButtonFormField<String?>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          value: cartState.customerId,
                          hint: const Text('Select Customer (Optional)'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('None (Walk-in)')),
                            ...customers.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ))
                          ],
                          onChanged: (val) {
                            if (val == null) {
                              ref.read(cartProvider.notifier).clearCustomer();
                            } else {
                              ref.read(cartProvider.notifier).setCustomer(val);
                            }
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error loading customers: $e'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Payment Methods
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['cash', 'upi', 'card', 'bank_transfer'].map((method) {
                        return ChoiceChip(
                          label: Text(method.toUpperCase()),
                          selected: _selectedPaymentMethod == method,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedPaymentMethod = method);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Partial Payment / Credit'),
                      value: _isPartialPayment,
                      onChanged: (val) {
                        setState(() {
                          _isPartialPayment = val ?? false;
                          if (_isPartialPayment && cartState.customerId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a customer for credit sales')),
                            );
                            _isPartialPayment = false;
                          }
                          if (!_isPartialPayment) {
                            _amountPaidController.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isPartialPayment)
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Amount Paid Now'),
                        controller: _amountPaidController,
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            CustomButton(
              text: 'Complete Payment (₹${cartState.totalAmount.toStringAsFixed(2)})',
              isLoading: _isLoading,
              onPressed: _processCheckout,
            ),
          ],
        ),
      ),
    );
  }
}
