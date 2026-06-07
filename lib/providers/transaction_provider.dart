import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  final NotificationService _notificationService = NotificationService();

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
    final id = await DatabaseHelper.instance.create(transaction);
    if (transaction.hasReminder && transaction.dueDate.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id,
        'Reminder: ${transaction.personName}',
        '${transaction.type == TransactionType.lend ? "Collect" : "Pay"} ${transaction.itemOrAmount}',
        transaction.dueDate,
      );
    }
    await fetchTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.update(transaction);
    
    // Handle notification
    if (transaction.id != null) {
      await _notificationService.cancelNotification(transaction.id!);
      if (transaction.hasReminder && 
          transaction.status == TransactionStatus.pending && 
          transaction.dueDate.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          transaction.id!,
          'Reminder: ${transaction.personName}',
          '${transaction.type == TransactionType.lend ? "Collect" : "Pay"} ${transaction.itemOrAmount}',
          transaction.dueDate,
        );
      }
    }
    
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.delete(id);
    await _notificationService.cancelNotification(id);
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

  // Reports data
  Map<String, double> get monthlyLentData {
    Map<String, double> data = {};
    for (var t in _transactions.where((t) => t.type == TransactionType.lend)) {
      String month = '${t.dateCreated.year}-${t.dateCreated.month.toString().padLeft(2, '0')}';
      data[month] = (data[month] ?? 0.0) + (double.tryParse(t.itemOrAmount) ?? 0.0);
    }
    return data;
  }

  Map<String, double> get monthlyBorrowedData {
    Map<String, double> data = {};
    for (var t in _transactions.where((t) => t.type == TransactionType.borrow)) {
      String month = '${t.dateCreated.year}-${t.dateCreated.month.toString().padLeft(2, '0')}';
      data[month] = (data[month] ?? 0.0) + (double.tryParse(t.itemOrAmount) ?? 0.0);
    }
    return data;
  }

  int get pendingCount => _transactions.where((t) => t.status == TransactionStatus.pending).length;
  int get completedCount => _transactions.where((t) => t.status == TransactionStatus.completed).length;
}
