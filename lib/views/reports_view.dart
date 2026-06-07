import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
        title: const Text('Analytics & Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => ExportService.exportToCsv(provider.transactions),
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCards(provider),
            const SizedBox(height: 24),
            _buildChartSection(
              context,
              'Lent vs Borrowed (Active)',
              _buildPieChart(provider),
            ),
            const SizedBox(height: 24),
            _buildChartSection(
              context,
              'Monthly Trend',
              _buildTrendChart(provider),
            ),
            const SizedBox(height: 24),
            _buildChartSection(
              context,
              'Transaction Status',
              _buildStatusChart(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(TransactionProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard('Total Lent', provider.totalLent.toStringAsFixed(2), Colors.green),
        _StatCard('Total Borrowed', provider.totalBorrowed.toStringAsFixed(2), Colors.blue),
        _StatCard('Pending', provider.pendingCount.toString(), Colors.orange),
        _StatCard('Completed', provider.completedCount.toString(), Colors.purple),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, String title, Widget chart) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(TransactionProvider provider) {
    final double total = provider.totalLent + provider.totalBorrowed;
    if (total == 0) return const Center(child: Text('No active financial data'));

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: provider.totalLent,
            title: 'Lent',
            color: Colors.green,
            radius: 50,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: provider.totalBorrowed,
            title: 'Borrowed',
            color: Colors.blue,
            radius: 50,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(TransactionProvider provider) {
    final lentData = provider.monthlyLentData;
    final borrowedData = provider.monthlyBorrowedData;
    
    if (lentData.isEmpty && borrowedData.isEmpty) {
      return const Center(child: Text('No data for trends'));
    }

    // Get unique months and sort them
    final allMonths = {...lentData.keys, ...borrowedData.keys}.toList()..sort();
    
    // Limit to last 6 months for readability
    final displayMonths = allMonths.length > 6 ? allMonths.sublist(allMonths.length - 6) : allMonths;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(lentData, borrowedData) * 1.2,
        barGroups: List.generate(displayMonths.length, (i) {
          final month = displayMonths[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(toY: lentData[month] ?? 0, color: Colors.green, width: 8),
              BarChartRodData(toY: borrowedData[month] ?? 0, color: Colors.blue, width: 8),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < displayMonths.length) {
                  final monthParts = displayMonths[value.toInt()].split('-');
                  return Text('${monthParts[1]}/${monthParts[0].substring(2)}', style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  double _getMaxY(Map<String, double> d1, Map<String, double> d2) {
    double max = 0;
    d1.values.forEach((v) => v > max ? max = v : null);
    d2.values.forEach((v) => v > max ? max = v : null);
    return max == 0 ? 100 : max;
  }

  Widget _buildStatusChart(TransactionProvider provider) {
    final int pending = provider.pendingCount;
    final int completed = provider.completedCount;
    
    if (pending == 0 && completed == 0) return const Center(child: Text('No transactions yet'));

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        sections: [
          PieChartSectionData(
            value: pending.toDouble(),
            title: 'Pending',
            color: Colors.orange,
            radius: 80,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: completed.toDouble(),
            title: 'Completed',
            color: Colors.purple,
            radius: 80,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
