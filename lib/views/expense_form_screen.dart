import 'package:flutter/material.dart';
import '../controllers/expense_controller.dart';
import '../models/expense.dart';
import '../models/user.dart';
import '../controllers/group_controller.dart';

class ExpenseFormScreen extends StatefulWidget {
  final int? groupId;
  final Expense? existingExpense;
  final int payerId;

  ExpenseFormScreen({
    this.groupId,
    this.existingExpense,
    required this.payerId
  });

  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final ExpenseController _controller = ExpenseController();

  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  int _selectedCategoryId = 1;
  List<int> _selectedParticipants = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      _titleCtrl.text = widget.existingExpense!.title;
      _amountCtrl.text = widget.existingExpense!.amount.toString();
      _selectedCategoryId = widget.existingExpense!.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingExpense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Expense" : "New Expense"),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _controller.deleteExpense(widget.existingExpense!.id);
                Navigator.pop(context);
              },
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: _amountCtrl, decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            SizedBox(height: 20),

            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: InputDecoration(labelText: 'Category'),
              items: [
                DropdownMenuItem(child: Row(children: [Icon(Icons.fastfood), SizedBox(width: 8), Text("Food")]), value: 1),
                DropdownMenuItem(child: Row(children: [Icon(Icons.home), SizedBox(width: 8), Text("Housing")]), value: 2),
                DropdownMenuItem(child: Row(children: [Icon(Icons.directions_car), SizedBox(width: 8), Text("Transportation")]), value: 3),
                DropdownMenuItem(child: Row(children: [Icon(Icons.sports_esports), SizedBox(width: 8), Text("Hobby")]), value: 4),
              ],
              onChanged: (val) => setState(() => _selectedCategoryId = val!),
            ),

            SizedBox(height: 20),

            if (widget.groupId != null && !isEditing)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Participants :", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: FutureBuilder<List<User>>(
                        future: GroupController().getMembers(widget.groupId!),
                        builder: (context, snapshot) {

                          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                          final members = snapshot.data!;

                          return ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return CheckboxListTile(
                                title: Text(member.username),
                                value: _selectedParticipants.contains(member.id),
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedParticipants.add(member.id);
                                    } else {
                                      _selectedParticipants.remove(member.id);
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            if (widget.groupId == null) Spacer(), // Pousse le bouton en bas si pas de liste

            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () async {
                if (isEditing) {
                  Expense depenseModifiee = Expense(
                      id: widget.existingExpense!.id,
                      title: _titleCtrl.text,
                      amount: double.parse(_amountCtrl.text),
                      expenseDate: widget.existingExpense!.expenseDate,
                      createdAt: widget.existingExpense!.createdAt,
                      payerId: widget.existingExpense!.payerId,
                      groupId: widget.groupId,
                      categoryId: _selectedCategoryId
                  );
                  await _controller.modifyExpense(depenseModifiee);
                } else {
                  await _controller.createExpense(
                      title: _titleCtrl.text,
                      amount: double.parse(_amountCtrl.text),
                      date: DateTime.now(),

                      payerId: widget.payerId,

                      categoryId: _selectedCategoryId,
                      groupId: widget.groupId,
                      participantsIds: _selectedParticipants
                  );
                }
                Navigator.pop(context);
              },
              child: Text("Confirm"),
            )),
          ],
        ),
      ),
    );
  }
}