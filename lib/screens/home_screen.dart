import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../services/local_notifications.dart';
import '../models/expense.dart';
import '../widgets/weekly_chart.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for notification taps
    LocalNotifications.onNotificationClick.listen((payload) {
      if (!mounted || payload == null) return;
      _showAddExpenseDialog(payload: payload);
    });
  }

  // Unified Dialog for both Manual Entry and Notification Clicks
  void _showAddExpenseDialog({String? payload}) {
    // Controllers for the Text Fields
    final amountController = TextEditingController();
    final merchantController = TextEditingController();
    final categoryController = TextEditingController(text: "Food");

    // If triggered by Notification, pre-fill the data
    if (payload != null) {
      final parts = payload.split('|');
      if (parts.length >= 2) {
        amountController.text = parts[0];
        merchantController.text = parts[1];
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(payload != null ? "✨ New Detected Expense" : "Add Manual Expense"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount Field
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixText: "₹ ",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              
              // Merchant Field
              TextField(
                controller: merchantController,
                decoration: const InputDecoration(
                  labelText: "Merchant / Description",
                  hintText: "e.g. Starbucks, Taxi, Rent",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Category Field
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final amountText = amountController.text;
              final merchantText = merchantController.text;

              if (amountText.isEmpty || merchantText.isEmpty) {
                return; // Don't save empty data
              }

              final double amount = double.tryParse(amountText) ?? 0.0;

              // Add to Database
              Provider.of<ExpenseProvider>(context, listen: false).addExpense(
                Expense(
                  amount: amount,
                  merchant: merchantText,
                  dateTime: DateTime.now(),
                  category: categoryController.text,
                  source: payload != null ? 'Notification' : 'Manual',
                )
              );

              Navigator.pop(ctx); // Close dialog
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Expense Saved!")),
              );
            },
            child: const Text("Save Expense"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        // No Actions (Test button removed)
      ),
      backgroundColor: Colors.grey.shade50,
      
      // THE NEW MANUAL ENTRY BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(payload: null), // Pass null for manual entry
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 1. Dashboard Graph
              if (provider.expenses.isNotEmpty) 
                WeeklyChart(expenses: provider.expenses),

              // 2. Expense List
              Expanded(
                child: provider.expenses.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("No expenses yet.\nWait for SMS or tap + to add.", 
                                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.expenses.length,
                        itemBuilder: (context, index) {
                          // Show newest expenses at the top (reverse index)
                          final reversedIndex = provider.expenses.length - 1 - index;
                          final expense = provider.expenses[reversedIndex];
                          
                          return Card(
                            elevation: 0,
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: expense.source == 'Manual' 
                                    ? Colors.orange.shade50 
                                    : Colors.blue.shade50,
                                child: Icon(
                                  expense.source == 'Manual' ? Icons.edit_note : Icons.sms, 
                                  color: expense.source == 'Manual' ? Colors.orange : Colors.blue,
                                  size: 20,
                                ),
                              ),
                              title: Text(expense.merchant, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${expense.category} • ${expense.formattedDate}"),
                              trailing: Text(
                                "₹${expense.amount.toStringAsFixed(0)}",
                                style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
