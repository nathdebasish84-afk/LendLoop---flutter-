import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'entry_form_view.dart';
import 'widgets/empty_state_widget.dart';

class SearchFilterView extends StatefulWidget {
  const SearchFilterView({super.key});

  @override
  State<SearchFilterView> createState() => _SearchFilterViewState();
}

class _SearchFilterViewState extends State<SearchFilterView> {
  String _searchQuery = '';
  TransactionType? _typeFilter;
  TransactionStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    
    final filteredTransactions = provider.transactions.where((t) {
      final matchesSearch = t.personName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.itemOrAmount.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _typeFilter == null || t.type == _typeFilter;
      final matchesStatus = _statusFilter == null || t.status == _statusFilter;
      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search people or items...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Lent',
                  selected: _typeFilter == TransactionType.lend,
                  onSelected: (val) => setState(() => _typeFilter = val ? TransactionType.lend : null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Borrowed',
                  selected: _typeFilter == TransactionType.borrow,
                  onSelected: (val) => setState(() => _typeFilter = val ? TransactionType.borrow : null),
                ),
                const SizedBox(width: 16),
                _FilterChip(
                  label: 'Pending',
                  selected: _statusFilter == TransactionStatus.pending,
                  onSelected: (val) => setState(() => _statusFilter = val ? TransactionStatus.pending : null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  selected: _statusFilter == TransactionStatus.completed,
                  onSelected: (val) => setState(() => _statusFilter = val ? TransactionStatus.completed : null),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const EmptyStateWidget(
                    title: 'No matches',
                    message: 'Try adjusting your filters or search terms.',
                    icon: Icons.search_off_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final t = filteredTransactions[index];
                      return Hero(
                        tag: 'trans_${t.id}',
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (t.type == TransactionType.lend ? Colors.green : Colors.blue).withOpacity(0.1),
                              child: Icon(
                                t.type == TransactionType.lend ? Icons.arrow_upward : Icons.arrow_downward,
                                color: t.type == TransactionType.lend ? Colors.green : Colors.blue,
                                size: 18,
                              ),
                            ),
                            title: Text(t.personName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(t.itemOrAmount),
                            trailing: Text(
                              t.status == TransactionStatus.pending ? 'Pending' : 'Done',
                              style: TextStyle(
                                fontSize: 12,
                                color: t.status == TransactionStatus.pending ? Colors.orange : Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EntryFormView(transaction: t)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      side: BorderSide(
        color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.3),
      ),
    );
  }
}
