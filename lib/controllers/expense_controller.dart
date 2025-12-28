import '../services/database_service.dart';
import '../models/expense.dart';
import '../models/expense_participant.dart';

class ExpenseController {

  Future<void> createExpense({
    required String title,
    required double amount,
    required DateTime date,
    required int payerId,
    required int categoryId,
    int? groupId,
    List<int>? participantsIds,
  }) async {

    Expense expense = Expense(
      id: 0,
      title: title,
      amount: amount,
      expenseDate: date,
      createdAt: DateTime.now(),
      payerId: payerId,
      groupId: groupId,
      categoryId: categoryId,
    );

    int newExpenseId = await DatabaseService().insertExpense(expense);

    if (participantsIds != null && participantsIds.isNotEmpty) {
      for (int userId in participantsIds) {
        ExpenseParticipant participant = ExpenseParticipant(
          expenseId: newExpenseId,
          userId: userId,
        );
        await DatabaseService().insertParticipant(participant);
      }
    }
  }

  Future<void> modifyExpense(Expense modifiedExpense) async {
    await DatabaseService().updateExpense(modifiedExpense);
  }

  Future<void> deleteExpense(int expenseId) async {
    await DatabaseService().deleteExpense(expenseId);
  }

}