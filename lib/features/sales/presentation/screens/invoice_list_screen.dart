import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';
import 'package:storemate/features/sales/presentation/providers/sales_provider.dart';
import 'package:storemate/core/widgets/app_card.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';
import 'package:decimal/decimal.dart';

enum DateFilter { all, today, yesterday, thisWeek, thisMonth, custom }

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateFilter _selectedFilter = DateFilter.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchData();
    });
  }

  void _fetchData() {
    String? startDateStr;
    String? endDateStr;
    
    final now = DateTime.now();

    switch (_selectedFilter) {
      case DateFilter.all:
        break;
      case DateFilter.today:
        startDateStr = DateTime(now.year, now.month, now.day).toIso8601String();
        endDateStr = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
        break;
      case DateFilter.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        startDateStr = DateTime(yesterday.year, yesterday.month, yesterday.day).toIso8601String();
        endDateStr = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59).toIso8601String();
        break;
      case DateFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        startDateStr = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).toIso8601String();
        endDateStr = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
        break;
      case DateFilter.thisMonth:
        startDateStr = DateTime(now.year, now.month, 1).toIso8601String();
        endDateStr = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
        break;
      case DateFilter.custom:
        if (_customStartDate != null) {
          startDateStr = _customStartDate!.toIso8601String();
        }
        if (_customEndDate != null) {
          endDateStr = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 23, 59, 59).toIso8601String();
        }
        break;
    }

    ref.read(salesHistoryProvider.notifier).fetchSales(
      searchText: _searchController.text.trim(),
      startDate: startDateStr,
      endDate: endDateStr,
      refresh: true,
    );
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = DateFilter.custom;
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesHistoryAsync = ref.watch(salesHistoryProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('Invoices')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pos'),
        icon: const Icon(Icons.add),
        label: const Text('New Sale'),
        backgroundColor: context.colors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.all(16),
            color: context.colors.card,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search invoice, customer, product...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: context.colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(DateFilter.all, 'All Time'),
                      _buildFilterChip(DateFilter.today, 'Today'),
                      _buildFilterChip(DateFilter.yesterday, 'Yesterday'),
                      _buildFilterChip(DateFilter.thisWeek, 'This Week'),
                      _buildFilterChip(DateFilter.thisMonth, 'This Month'),
                      _buildFilterChip(DateFilter.custom, 'Custom'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sales List
          Expanded(
            child: salesHistoryAsync.when(
              data: (sales) {
                if (sales.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppEmptyState(
                      icon: Icons.receipt_long,
                      title: _searchController.text.isEmpty && _selectedFilter == DateFilter.all 
                          ? 'No invoices yet' 
                          : 'No sales found',
                      explanation: _searchController.text.isEmpty && _selectedFilter == DateFilter.all
                          ? 'Complete your first sale to see invoices here.'
                          : 'Try adjusting your search or date filters.',
                      actionLabel: _searchController.text.isEmpty && _selectedFilter == DateFilter.all
                          ? 'New Sale'
                          : 'Clear Filters',
                      onAction: () {
                        if (_searchController.text.isEmpty && _selectedFilter == DateFilter.all) {
                          context.push('/pos');
                        } else {
                          setState(() {
                            _searchController.clear();
                            _selectedFilter = DateFilter.all;
                          });
                          _fetchData();
                        }
                      },
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _fetchData(),
                  color: context.colors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                    itemCount: sales.length,
                    separatorBuilder: (a, b) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return AppCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(sale.invoiceNumber, style: AppTextStyles.titleSm.copyWith(color: context.colors.textPrimary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: sale.status == 'refunded' ? context.colors.danger.withValues(alpha: 0.1) : ((sale.payments.isNotEmpty && sale.payments.first.paymentMethod == 'credit') && sale.amountDue > Decimal.zero ? context.colors.warning.withValues(alpha: 0.1) : context.colors.success.withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  sale.status == 'refunded' ? 'REFUNDED' : ((sale.payments.isNotEmpty && sale.payments.first.paymentMethod == 'credit') && sale.amountDue > Decimal.zero ? 'CREDIT' : 'PAID'),
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: sale.status == 'refunded' ? context.colors.danger : ((sale.payments.isNotEmpty && sale.payments.first.paymentMethod == 'credit') && sale.amountDue > Decimal.zero ? context.colors.warning : context.colors.success),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                sale.customer?.name ?? 'Walk-in Customer',
                                style: AppTextStyles.bodyMd.copyWith(color: context.colors.textSecondary)
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${DateFormat.yMd().add_jm().format(sale.createdAt ?? DateTime.now())} • ${sale.items.length} item${sale.items.length != 1 ? 's' : ''}',
                                    style: AppTextStyles.labelSm.copyWith(color: context.colors.textTertiary)
                                  ),
                                  Text(
                                    '₹${sale.netAmount.toDouble().toStringAsFixed(2)}',
                                    style: AppTextStyles.titleMd.copyWith(color: context.colors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => context.push('/sales/${sale.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: context.colors.primary)),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Failed to load invoices',
                  explanation: e.toString(),
                  actionLabel: 'Retry',
                  onAction: () => _fetchData(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(DateFilter filter, String label) {
    final isSelected = _selectedFilter == filter;
    
    // Display chosen dates if custom is selected
    String displayLabel = label;
    if (filter == DateFilter.custom && isSelected && _customStartDate != null && _customEndDate != null) {
      displayLabel = '${DateFormat.MMMd().format(_customStartDate!)} - ${DateFormat.MMMd().format(_customEndDate!)}';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(displayLabel),
        selected: isSelected,
        onSelected: (selected) {
          if (filter == DateFilter.custom) {
            _selectCustomDateRange();
          } else {
            setState(() {
              _selectedFilter = filter;
            });
            _fetchData();
          }
        },
        backgroundColor: context.colors.background,
        selectedColor: context.colors.primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: isSelected ? context.colors.primary : context.colors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? context.colors.primary : context.colors.border,
          ),
        ),
      ),
    );
  }
}
