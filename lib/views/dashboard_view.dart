import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'entry_form_view.dart';
import 'search_filter_view.dart';
import 'reports_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LendLoop', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchFilterView()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsView()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchTransactions,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(provider),
              const SizedBox(height: 24),
              _buildSectionTitle('Upcoming Reminders'),
              const SizedBox(height: 8),
              _buildUpcomingReminders(provider),
              const SizedBox(height: 24),
              _buildSectionTitle('Recent Transactions'),
              const SizedBox(height: 8),
              _buildRecentTransactions(provider),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EntryFormView()),
        ),
        label: const Text('Add Entry'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards(TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Lent',
            amount: provider.totalLent,
            color: Colors.green,
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Total Borrowed',
            amount: provider.totalBorrowed,
            color: Colors.blue,
            icon: Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildUpcomingReminders(TransactionProvider provider) {
    final reminders = provider.upcomingReminders;
    if (reminders.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No upcoming reminders'),
        ),
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final t = reminders[index];
          return Card(
            margin: const EdgeInsets.only(right: 12),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.personName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(t.itemOrAmount, style: const TextStyle(fontSize: 18, color: Colors.green)),
                  const Spacer(),
                  Text('Due: ${t.dueDate.day}/${t.dueDate.month}/${t.dueDate.year}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.transactions.isEmpty) return const Text('No transactions yet');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.transactions.length > 5 ? 5 : provider.transactions.length,
      itemBuilder: (context, index) {
        final t = provider.transactions[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: t.type == TransactionType.lend ? Colors.green.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
              child: Icon(
                t.type == TransactionType.lend ? Icons.arrow_upward : Icons.arrow_downward,
                color: t.type == TransactionType.lend ? Colors.green : Colors.blue,
              ),
            ),
            title: Text(t.personName),
            subtitle: Text(t.itemOrAmount),
            trailing: Text(t.status == TransactionStatus.pending ? 'Pending' : 'Completed'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EntryFormView(transaction: t)),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({required this.title, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
