import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await DatabaseHelper.instance.readAllTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.create(transaction);
    await fetchTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.update(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.delete(id);
    await fetchTransactions();
  }

  double get totalLent {
    return _transactions
        .where((t) => t.type == TransactionType.lend && t.status == TransactionStatus.pending)
        .fold(0.0, (sum, t) => sum + (double.tryParse(t.itemOrAmount) ?? 0.0));
  }

  double get totalBorrowed {
    return _transactions
        .where((t) => t.type == TransactionType.borrow && t.status == TransactionStatus.pending)
        .fold(0.0, (sum, t) => sum + (double.tryParse(t.itemOrAmount) ?? 0.0));
  }

  List<TransactionModel> get upcomingReminders {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.status == TransactionStatus.pending && t.dueDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}
