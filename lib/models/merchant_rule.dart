class MerchantRule {
  final int? id;
  final String keyword;
  final String category;

  MerchantRule({
    this.id,
    required this.keyword,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'keyword': keyword,
      'category': category,
    };
  }

  factory MerchantRule.fromMap(Map<String, dynamic> map) {
    return MerchantRule(
      id: map['id'],
      keyword: map['keyword'],
      category: map['category'],
    );
  }
}
