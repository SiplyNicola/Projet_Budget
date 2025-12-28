import 'package:flutter/material.dart';
import '../controllers/stats_controller.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class PersonalExpenseScreen extends StatefulWidget {
  final int userId;

  PersonalExpenseScreen({required this.userId});

  @override
  _PersonalExpenseScreenState createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
  final StatsController _statsCtrl = StatsController();

  IconData _getIconForCategory(int catId) {
    switch (catId) {
      case 1: return Icons.fastfood;
      case 2: return Icons.home;
      case 3: return Icons.directions_car;
      case 4: return Icons.sports_esports;
      default: return Icons.monetization_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Dépenses Perso"),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _statsCtrl.getPersoExpenses(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Aucune dépense personnelle."),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final expense = snapshot.data![index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Icon(_getIconForCategory(expense.categoryId), color: Colors.orange[800]),
                  ),
                  title: Text(expense.title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(expense.expenseDate.toString().split(' ')[0]),
                  trailing: Text(
                    "${expense.amount.toStringAsFixed(2)} €",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                        context,
                        '/expense_form',
                        arguments: {
                          'groupeId': null,
                          'existingExpense': expense,
                          'payerId': widget.userId
                        }
                    ).then((_) => setState(() {}));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
              context,
              '/expense_form',
              arguments: {
                'groupeId': null,
                'payerId': widget.userId
              }
          ).then((_) => setState(() {}));
        },
      ),
    );
  }
}