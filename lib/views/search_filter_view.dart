import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'entry_form_view.dart';

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
          decoration: const InputDecoration(
            hintText: 'Search by name or item...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Lent'),
                  selected: _typeFilter == TransactionType.lend,
                  onSelected: (val) => setState(() => _typeFilter = val ? TransactionType.lend : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Borrowed'),
                  selected: _typeFilter == TransactionType.borrow,
                  onSelected: (val) => setState(() => _typeFilter = val ? TransactionType.borrow : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _statusFilter == TransactionStatus.pending,
                  onSelected: (val) => setState(() => _statusFilter = val ? TransactionStatus.pending : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _statusFilter == TransactionStatus.completed,
                  onSelected: (val) => setState(() => _statusFilter = val ? TransactionStatus.completed : null),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final t = filteredTransactions[index];
                return ListTile(
                  leading: Icon(
                    t.type == TransactionType.lend ? Icons.arrow_upward : Icons.arrow_downward,
                    color: t.type == TransactionType.lend ? Colors.green : Colors.blue,
                  ),
                  title: Text(t.personName),
                  subtitle: Text(t.itemOrAmount),
                  trailing: Text(t.status == TransactionStatus.pending ? 'Pending' : 'Completed'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EntryFormView(transaction: t)),
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
