import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? expense;
  const AddExpenseSheet({super.key, this.expense});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late DateTime _selectedDateTime;
  String _selectedCategory = 'Food';
  bool _isEditing = false;

  final List<String> _categories = [
    'Food', 'Travel', 'Shopping', 'Entertainment', 'Bills & Utilities', 'Groceries', 'Health', 'Education', 'Others'
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.expense != null;
    _amountController = TextEditingController(text: widget.expense?.amount.toString() ?? '');
    _merchantController = TextEditingController(text: widget.expense?.merchant ?? '');
    _selectedDateTime = widget.expense?.dateTime ?? DateTime.now();
    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Edit Expense' : 'Add Expense',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Amount (₹)'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _merchantController,
              decoration: _inputDecoration('Merchant Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration('Category'),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.textGrey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date & Time', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                          Text(
                            '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isEditing ? 'Update Expense' : 'Save Expense'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        final updatedExpense = Expense(
          id: widget.expense!.id,
          amount: double.parse(_amountController.text),
          dateTime: _selectedDateTime,
          merchant: _merchantController.text,
          category: _selectedCategory,
          source: widget.expense!.source,
          smsId: widget.expense!.smsId,
        );
        context.read<ExpenseProvider>().updateExpense(updatedExpense);
      } else {
        final expense = Expense(
          amount: double.parse(_amountController.text),
          dateTime: _selectedDateTime,
          merchant: _merchantController.text,
          category: _selectedCategory,
          source: 'Manual',
        );
        context.read<ExpenseProvider>().addExpense(expense);
      }
      Navigator.pop(context);
    }
  }
}
