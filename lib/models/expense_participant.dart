class ExpenseParticipant {
  final int expenseId;
  final int userId;

  ExpenseParticipant({
    required this.expenseId,
    required this.userId,
  });

  factory ExpenseParticipant.fromMap(Map<String, dynamic> map) {
    return ExpenseParticipant(
      expenseId: map['expense_id'],
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expense_id': expenseId,
      'user_id': userId,
    };
  }
}