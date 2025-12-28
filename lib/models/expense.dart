class Expense {
  final int id;
  final String title;
  final double amount;
  final DateTime expenseDate;
  final DateTime createdAt;
  final int payerId; // The person who paid upfront
  final int? groupId; // Nullable for personal expenses
  final int categoryId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.expenseDate,
    required this.createdAt,
    required this.payerId,
    this.groupId,
    required this.categoryId,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(map['expense_date']),
      createdAt: DateTime.parse(map['created_at']),
      payerId: map['payer_id'],
      groupId: map['group_id'],
      categoryId: map['category_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'payer_id': payerId,
      'group_id': groupId,
      'category_id': categoryId,
    };
  }
}