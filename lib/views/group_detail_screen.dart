import 'package:flutter/material.dart';
import '../controllers/group_controller.dart';
import '../models/group.dart';
import '../controllers/stats_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/expense_controller.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  final int currentUserId;

  GroupDetailScreen({required this.group, required this.currentUserId});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final int currentUserId = 1;
  final GroupController _groupCtrl = GroupController();
  final StatsController _statsCtrl = StatsController();
  final ExpenseController _expCtrl = ExpenseController();

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.currentUserId == widget.group.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () async {
              String code = await _groupCtrl.getGroupCode(widget.group.id);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Invite members"),
                  content: SelectableText(code, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),

          if (isOwner) ...[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _displayModificationBox(context),
            ),
            IconButton(
              icon: Icon(Icons.delete_forever),
              color: Colors.red[100],
              onPressed: () => _confirmGroupSuppression(context),
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => _confirmLeaveGroup(context),
            ),
          ]
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: FutureBuilder<List<UserBalance>>(
              future: _statsCtrl.calculateBalance(widget.group.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var balances = snapshot.data!;
                if (balances.isEmpty) return Center(child: Text("No balances"));

                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: balances.map((balance) {

                    bool isNegative = balance.amount < -0.01;
                    bool isPositive = balance.amount > 0.01;
                    print(isNegative);
                    print(isPositive);
                    print(balance.amount);


                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ActionChip(
                        avatar: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(balance.username.isNotEmpty ? balance.username[0].toUpperCase() : "?"),
                        ),
                        label: Text("${balance.username} : ${balance.amount.toStringAsFixed(2)}€"),

                        backgroundColor: isNegative
                            ? Colors.red[100]
                            : ((isPositive) ? Colors.green[100] : Colors.grey[200]),

                        onPressed: () {

                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ExpenseWithUsername>>(
              future: _statsCtrl.getGroupExpensesWithUsernames(widget.group.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var list = snapshot.data!;

                if (list.isEmpty) return Center(child: Text("No expenses"));

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.monetization_on, size: 20),
                          backgroundColor: Colors.blue[50],
                        ),
                        title: Text(item.expense.title, style: TextStyle(fontWeight: FontWeight.bold)),

                        subtitle: Text("Paid by ${item.payerUsername}"),

                        trailing: Text(
                          "${item.expense.amount.toStringAsFixed(2)} €",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                              context,
                              '/expense_form',
                              arguments: {
                                'groupId': widget.group.id,
                                'existingExpense': item.expense,
                                'payerId': widget.currentUserId
                              }
                          ).then((_) => setState(() {}));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
              context,
              '/expense_form',
              arguments: {
                'groupId': widget.group.id,
                'payerId': widget.currentUserId
              }
          ).then((_) => setState(() {}));
        },
      ),
    );
  }

  void _displayModificationBox(BuildContext context) {
    TextEditingController _editCtrl = TextEditingController(text: widget.group.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit group"),
        content: TextField(controller: _editCtrl, decoration: InputDecoration(labelText: "New name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _groupCtrl.modifyGroupName(widget.group.id, _editCtrl.text, widget.currentUserId);
                Navigator.pop(ctx);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  // Pour le PROPRIÉTAIRE : Supprimer définitivement
  void _confirmGroupSuppression(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete group ?"),
        content: Text("Warning: this will delete all expenses and history for ALL members. This action is irreversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _groupCtrl.deleteGroup(widget.group.id, widget.currentUserId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text("Delete"),
          )
        ],
      ),
    );
  }

  void _confirmLeaveGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Leave group ?"),
        content: Text("You will no longer have access to the expenses."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _groupCtrl.leaveGroup(widget.group.id, widget.currentUserId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text("Leave"),
          )
        ],
      ),
    );
  }
}
