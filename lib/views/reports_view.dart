import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../services/export_service.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => ExportService.exportToCsv(provider.transactions),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportCard(
            context,
            'Summary',
            [
              _ReportRow('Total Active Lent', provider.totalLent.toStringAsFixed(2), Colors.green),
              _ReportRow('Total Active Borrowed', provider.totalBorrowed.toStringAsFixed(2), Colors.blue),
              _ReportRow('Pending Items', provider.transactions.where((t) => t.status == TransactionStatus.pending).length.toString(), Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          // Additional report cards can be added here
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, List<_ReportRow> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...rows.map((row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(row.label),
                  Text(row.value, style: TextStyle(fontWeight: FontWeight.bold, color: row.color)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ReportRow {
  final String label;
  final String value;
  final Color color;

  _ReportRow(this.label, this.value, this.color);
}
