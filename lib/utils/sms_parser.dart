import '../models/expense.dart';

class SmsParser {
  // Regex to find the Amount (matches "Rs. 500", "INR 500", "Rs 500.00", "500.00")
  static final RegExp amountRegExp = RegExp(
      r'(?:(?:RS|INR|Rs\.?|INR\.?|₹)\s?)\s*([0-9,]+(?:\.[0-9]+)?)',
      caseSensitive: false);

  // Regex to find transaction type (Debit/Spent/Sent)
  static final RegExp debitRegExp = RegExp(
      r'(debited|spent|paid|sent|transferred|purchase|txn|transaction)',
      caseSensitive: false);

  // Regex for merchant detection
  static final RegExp merchantRegExp = RegExp(
      r'(?:at|to|vpa|spent on|paid to)\s+([a-zA-Z0-9\.\s\-@&]+?)(?:\s+on|\s+at|\s+using|\s+link|\.\s|for|ref|$)',
      caseSensitive: false);

  static Expense? parseSms(String body, String sender, DateTime timestamp) {
    // 1. Check for keywords (Sent, Paid, Debited)
    if (!debitRegExp.hasMatch(body.toLowerCase())) {
      return null;
    }

    // 2. Extract Amount
    final amountMatch = amountRegExp.firstMatch(body);
    if (amountMatch == null) {
      return null;
    }

    String rawAmount = amountMatch.group(1)!.replaceAll(',', '');
    double amount = double.tryParse(rawAmount) ?? 0.0;

    // 3. Extract Merchant
    String merchant = sender; // Default to sender name
    
    final merchantMatch = merchantRegExp.firstMatch(body);
    if (merchantMatch != null) {
      merchant = merchantMatch.group(1)!.trim();
    }

    // 4. Return Expense Object
    return Expense(
      amount: amount,
      dateTime: timestamp,
      merchant: merchant,
      category: 'Uncategorized',
      source: 'Notification', // <--- FIXED: Added the required 'source' field
    );
  }
}