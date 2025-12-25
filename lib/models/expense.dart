class Expense {
  final int? id;
  final double amount;
  final DateTime dateTime;
  final String merchant;
  final String category;
  final String source; // 'SMS' or 'Manual'
  final String? smsId;

  Expense({
    this.id,
    required this.amount,
    required this.dateTime,
    required this.merchant,
    required this.category,
    required this.source,
    this.smsId,
  });

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date_time': dateTime.toIso8601String(),
      'merchant': merchant,
      'category': category,
      'source': source,
      'sms_id': smsId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      dateTime: DateTime.parse(map['date_time']),
      merchant: map['merchant'],
      category: map['category'],
      source: map['source'],
      smsId: map['sms_id'],
    );
  }
}
