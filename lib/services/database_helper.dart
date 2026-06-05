import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lendloop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personName TEXT NOT NULL,
        itemOrAmount TEXT NOT NULL,
        description TEXT,
        dateCreated TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        hasReminder INTEGER NOT NULL,
        type INTEGER NOT NULL,
        status INTEGER NOT NULL
      )
    ''');
  }

  Future<int> create(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<TransactionModel?> readTransaction(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'transactions',
      columns: ['id', 'personName', 'itemOrAmount', 'description', 'dateCreated', 'dueDate', 'hasReminder', 'type', 'status'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<TransactionModel>> readAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'dateCreated DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> update(TransactionModel transaction) async {
    final db = await instance.database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
