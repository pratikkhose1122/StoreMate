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

class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
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
      appBar: AppBar(title: const Text('Sales History')),
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
                      icon: Icons.history,
                      title: 'No sales found',
                      explanation: 'Try adjusting your search or date filters.',
                      actionLabel: 'Clear Filters',
                      onAction: () {
                        setState(() {
                          _searchController.clear();
                          _selectedFilter = DateFilter.all;
                        });
                        _fetchData();
                      },
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _fetchData(),
                  color: context.colors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sales.length,
                    separatorBuilder: (a, b) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return AppCard(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(sale.invoiceNumber, style: AppTextStyles.productMd.copyWith(color: context.colors.textPrimary)),
                          subtitle: Text(
                            '${sale.customer?.name ?? 'Walk-in'} • ${DateFormat.yMd().add_jm().format(sale.createdAt ?? DateTime.now())}',
                            style: AppTextStyles.bodySm.copyWith(color: context.colors.textSecondary)
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${sale.netAmount.toDouble().toStringAsFixed(2)}',
                                style: AppTextStyles.labelLg.copyWith(color: context.colors.textPrimary),
                              ),
                              if (sale.amountDue > Decimal.zero)
                                Text(
                                  'Due: ₹${sale.amountDue.toDouble().toStringAsFixed(2)}',
                                  style: AppTextStyles.labelSm.copyWith(color: context.colors.danger),
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
                  title: 'Failed to load sales history',
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
