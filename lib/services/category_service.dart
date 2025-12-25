import '../models/merchant_rule.dart';

class CategoryService {
  static const Map<String, List<String>> keywordMap = {
    'Food': ['swiggy', 'zomato', 'restaurant', 'cafe', 'bake', 'hotel', 'eats', 'food', 'tiffin', 'canteen'],
    'Travel': ['uber', 'ola', 'rapido', 'irctc', 'metro', 'fuel', 'petrol', 'diesel', 'shell', 'indigo', 'airtel'],
    'Shopping': ['amazon', 'flipkart', 'myntra', 'ajio', 'nykaa', 'zara', 'h&m', 'mall', 'mart', 'market'],
    'Entertainment': ['netflix', 'hotstar', 'prime', 'pvr', 'inox', 'bookmyshow', 'spotify', 'youtube'],
    'Bills & Utilities': ['recharge', 'electricity', 'water', 'gas', 'postpaid', 'broadband', 'jio', 'vi', 'bill', 'insurance'],
    'Groceries': ['bigbasket', 'blinkit', 'zepto', 'instamart', 'milk', 'grocery', 'supermarket', 'reliance fresh'],
    'Health': ['apollo', 'pharmeasy', 'medplus', 'hospital', 'clinic', 'dentist', 'gym', 'health', 'fitness'],
    'Education': ['udemy', 'coursera', 'college', 'school', 'fee', 'books', 'stationary'],
  };

  static String detectCategory(String merchant, List<MerchantRule> userRules) {
    String merchantLower = merchant.toLowerCase();

    // Priority 1: User-defined rules
    for (var rule in userRules) {
      if (merchantLower.contains(rule.keyword.toLowerCase())) {
        return rule.category;
      }
    }

    // Priority 2: Built-in keyword matching
    for (var entry in keywordMap.entries) {
      for (var keyword in entry.value) {
        if (merchantLower.contains(keyword)) {
          return entry.key;
        }
      }
    }

    // Fallback
    return "Others";
  }

  static String getEmojiForCategory(String category) {
    switch (category) {
      case 'Food': return '🍔';
      case 'Travel': return '🚗';
      case 'Shopping': return '🛍️';
      case 'Entertainment': return '🎬';
      case 'Bills & Utilities': return '📄';
      case 'Groceries': return '🛒';
      case 'Health': return '🏥';
      case 'Education': return '📚';
      default: return '💰';
    }
  }
}
