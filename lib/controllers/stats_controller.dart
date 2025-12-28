import '../services/database_service.dart';
import '../models/expense.dart';
import '../models/user.dart';

class StatsController {

  Future<List<Expense>> getGroupExpenses(int groupId) async {
    return await DatabaseService().getExpensesByGroup(groupId);
  }

  Future<List<Expense>> getPersoExpenses(int userId) async {
    return await DatabaseService().getPersonalExpenses(userId);
  }

  Future<double> getMonthExpensesAmount(int userId) async {
    DateTime now = DateTime.now();
    List<Expense> allExpenses = await DatabaseService().getAllExpensesForUser(userId);

    double total = 0;
    for (var expense in allExpenses) {
      if (expense.expenseDate.month == now.month && expense.expenseDate.year == now.year) {
        total += expense.amount;
      }
    }
    return total;
  }

  Future<Map<int, double>> getExpensesByCategory(int userId) async {
    List<Expense> allExpenses = await DatabaseService().getAllExpensesForUser(userId);
    Map<int, double> stats = {};

    for (var expense in allExpenses) {
      if (!stats.containsKey(expense.categoryId)) {
        stats[expense.categoryId] = 0.0;
      }
      stats[expense.categoryId] = stats[expense.categoryId]! + expense.amount;
    }
    return stats;
  }

  Future<List<UserBalance>> calculateBalance(int groupId) async {
    List<Expense> expenses = await DatabaseService().getExpensesByGroup(groupId);

    List<User> members = await DatabaseService().getGroupMembers(groupId);

    Map<int, double> tempBalances = {};

    for (var m in members) {
      tempBalances[m.id] = 0.0;
    }

    for (var expense in expenses) {
      tempBalances[expense.payerId] = (tempBalances[expense.payerId] ?? 0) + expense.amount;

      List<int> participantsIds = await DatabaseService().getParticipantsForExpense(expense.id);

      if (participantsIds.isNotEmpty) {
        double individualPart = expense.amount / participantsIds.length;

        for (int userId in participantsIds) {
          tempBalances[userId] = (tempBalances[userId] ?? 0) - individualPart;
        }
      }
    }

    List<UserBalance> results = [];

    tempBalances.forEach((userId, amount) {
      String username = members.firstWhere(
              (m) => m.id == userId,
          orElse: () => User(id: 0, username: "Inconnu", email: "", password: "", createdAt: DateTime.now())
      ).username;

      results.add(UserBalance(userId, username, amount));
    });

    return results;
  }

  Future<List<ExpenseWithUsername>> getGroupExpensesWithUsernames(int groupeId) async {
    List<Expense> expenses = await DatabaseService().getExpensesByGroup(groupeId);

    List<User> members = await DatabaseService().getGroupMembers(groupeId);

    return expenses.map((dep) {
      String pseudo = members.firstWhere(
              (m) => m.id == dep.payerId,
          orElse: () => User(id: 0, username: "Inconnu", email: "", password: "", createdAt: DateTime.now())
      ).username;

      return ExpenseWithUsername(dep, pseudo);
    }).toList();
  }
}

class UserBalance {
  final int userId;
  final String username;
  final double amount;

  UserBalance(this.userId, this.username, this.amount);
}

class ExpenseWithUsername {
  final Expense expense;
  final String payerUsername;

  ExpenseWithUsername(this.expense, this.payerUsername);
}