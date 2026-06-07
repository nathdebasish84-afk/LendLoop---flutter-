import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'entry_form_view.dart';
import 'widgets/empty_state_widget.dart';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LendLoop', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('Manage your items & cash', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: provider.fetchTransactions,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(provider),
              const SizedBox(height: 32),
              _buildSectionHeader('Upcoming Reminders'),
              const SizedBox(height: 12),
              _buildUpcomingReminders(provider),
              const SizedBox(height: 32),
              _buildSectionHeader('Recent Activity'),
              const SizedBox(height: 12),
              _buildRecentTransactions(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
    );
  }

  Widget _buildSummaryCards(TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Lent Out',
            amount: provider.totalLent,
            color: Colors.green,
            icon: Icons.upload_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Borrowed',
            amount: provider.totalBorrowed,
            color: Colors.blue,
            icon: Icons.download_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingReminders(TransactionProvider provider) {
    final reminders = provider.upcomingReminders;
    if (reminders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No pending reminders for now.', textAlign: TextAlign.center),
      );
    }
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final t = reminders[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${t.dueDate.day}/${t.dueDate.month}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      t.personName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      t.itemOrAmount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.transactions.isEmpty) {
      return const EmptyStateWidget(
        title: 'Start tracking',
        message: 'Tap the + button to add your first transaction.',
        icon: Icons.receipt_long_outlined,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.transactions.length > 5 ? 5 : provider.transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final t = provider.transactions[index];
        return Hero(
          tag: 'trans_${t.id}',
          child: Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (t.type == TransactionType.lend ? Colors.green : Colors.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  t.type == TransactionType.lend ? Icons.arrow_upward : Icons.arrow_downward,
                  color: t.type == TransactionType.lend ? Colors.green : Colors.blue,
                ),
              ),
              title: Text(t.personName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(t.itemOrAmount),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: t.status == TransactionStatus.pending ? Colors.orange.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t.status == TransactionStatus.pending ? 'Pending' : 'Done',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: t.status == TransactionStatus.pending ? Colors.orange : Colors.purple,
                  ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            amount.toStringAsFixed(2),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
