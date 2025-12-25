import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';

class MerchantRulesScreen extends StatefulWidget {
  const MerchantRulesScreen({super.key});

  @override
  State<MerchantRulesScreen> createState() => _MerchantRulesScreenState();
}

class _MerchantRulesScreenState extends State<MerchantRulesScreen> {
  final _keywordController = TextEditingController();
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food', 'Travel', 'Shopping', 'Entertainment', 'Bills & Utilities', 'Groceries', 'Health', 'Education', 'Others'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Rules')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: InputDecoration(
                      hintText: 'Keyword (e.g. Swiggy)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppTheme.primaryBlue),
                  onPressed: _addRule,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: provider.rules.length,
              itemBuilder: (context, index) {
                final rule = provider.rules[index];
                return ListTile(
                  title: Text(rule.keyword, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(rule.category, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed, size: 20),
                    onPressed: () => provider.deleteRule(rule.id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addRule() {
    if (_keywordController.text.isNotEmpty) {
      context.read<ExpenseProvider>().addRule(_keywordController.text, _selectedCategory);
      _keywordController.clear();
    }
  }
}
