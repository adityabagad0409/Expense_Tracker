import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/merchant_rule.dart';
import '../services/database_service.dart';
import '../services/category_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  
  List<Expense> _expenses = [];
  List<MerchantRule> _rules = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  List<MerchantRule> get rules => _rules;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await _db.getAllExpenses();
    _rules = await _db.getAllMerchantRules();

    _isLoading = false;
    notifyListeners();
  }

  // Expense Actions
  Future<void> addExpense(Expense expense) async {
    final category = CategoryService.detectCategory(expense.merchant, _rules);
    final finalExpense = Expense(
      amount: expense.amount,
      dateTime: expense.dateTime,
      merchant: expense.merchant,
      category: category,
      source: expense.source,
      smsId: expense.smsId,
    );
    
    await _db.insertExpense(finalExpense);
    await loadData();
  }

  Future<void> updateExpense(Expense expense) async {
    await _db.updateExpense(expense);
    await loadData();
  }

  Future<void> deleteExpense(int id) async {
    await _db.deleteExpense(id);
    await loadData();
  }

  // Merchant Rule Actions
  Future<void> addRule(String keyword, String category) async {
    await _db.insertMerchantRule(MerchantRule(keyword: keyword, category: category));
    await loadData();
    // Re-categorize existing expenses based on new rule? 
    // Usually, we just apply to future, but could re-scan.
  }

  Future<void> deleteRule(int id) async {
    await _db.deleteMerchantRule(id);
    await loadData();
  }

  // Calculations
  double get todayTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.dateTime.day == now.day && 
                      e.dateTime.month == now.month && 
                      e.dateTime.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get monthTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.dateTime.month == now.month && 
                      e.dateTime.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get yearTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.dateTime.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  Map<int, double> get monthlySpending {
    Map<int, double> data = {};
    // Initialize all months of current year
    for (int i = 1; i <= 12; i++) {
      data[i] = 0;
    }
    
    final currentYear = DateTime.now().year;
    for (var e in _expenses) {
      if (e.dateTime.year == currentYear) {
        data[e.dateTime.month] = (data[e.dateTime.month] ?? 0) + e.amount;
      }
    }
    return data;
  }

  Future<void> resetAll() async {
    await _db.clearAllData();
    await loadData();
  }
}
