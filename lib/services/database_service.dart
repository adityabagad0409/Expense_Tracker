import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/merchant_rule.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        date_time TEXT,
        merchant TEXT,
        category TEXT,
        source TEXT,
        sms_id TEXT UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE merchant_rules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        keyword TEXT UNIQUE,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // Expense CRUD
  Future<int> insertExpense(Expense expense) async {
    try {
      Database db = await database;
      return await db.insert('expenses', expense.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } catch (e) {
      print('Error inserting expense: $e');
      return 0;
    }
  }

  Future<List<Expense>> getAllExpenses() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'date_time DESC');
      return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
    } catch (e) {
      print('Error fetching expenses: $e');
      return [];
    }
  }

  Future<int> updateExpense(Expense expense) async {
    try {
      Database db = await database;
      return await db.update('expenses', expense.toMap(),
          where: 'id = ?', whereArgs: [expense.id]);
    } catch (e) {
      print('Error updating expense: $e');
      return 0;
    }
  }

  Future<int> deleteExpense(int id) async {
    try {
      Database db = await database;
      return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting expense: $e');
      return 0;
    }
  }

  // Merchant Rule CRUD
  Future<int> insertMerchantRule(MerchantRule rule) async {
    try {
      Database db = await database;
      return await db.insert('merchant_rules', rule.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting merchant rule: $e');
      return 0;
    }
  }

  Future<List<MerchantRule>> getAllMerchantRules() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query('merchant_rules');
      return List.generate(maps.length, (i) => MerchantRule.fromMap(maps[i]));
    } catch (e) {
      print('Error fetching merchant rules: $e');
      return [];
    }
  }

  Future<int> deleteMerchantRule(int id) async {
    try {
      Database db = await database;
      return await db.delete('merchant_rules', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting merchant rule: $e');
      return 0;
    }
  }

  Future<void> clearAllData() async {
    try {
      Database db = await database;
      await db.delete('expenses');
      await db.delete('merchant_rules');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
