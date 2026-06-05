import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';

class ExportService {
  static Future<void> exportToCsv(List<TransactionModel> transactions) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      "ID",
      "Person Name",
      "Item/Amount",
      "Description",
      "Date Created",
      "Due Date",
      "Type",
      "Status"
    ]);

    for (var t in transactions) {
      rows.add([
        t.id,
        t.personName,
        t.itemOrAmount,
        t.description,
        t.dateCreated.toIso8601String(),
        t.dueDate.toIso8601String(),
        t.type == TransactionType.lend ? "Lend" : "Borrow",
        t.status == TransactionStatus.pending ? "Pending" : "Completed"
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/lendloop_export_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);

    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'LendLoop Data Export');
  }
}
