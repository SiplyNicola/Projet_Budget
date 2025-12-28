import 'package:flutter/material.dart';
import '../controllers/stats_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/group_controller.dart';
import '../models/group.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StatsController _statsController = StatsController();
  final AuthController _authController = AuthController();
  final GroupController _groupController = GroupController();

  late int currentUserId;

  final _groupNameCtrl = TextEditingController();
  final _GroupCodeCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      currentUserId = args;
    } else {
      currentUserId = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BUDG€T"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.person),
            itemBuilder: (context) => [
              PopupMenuItem(child: Text("Logout"), value: 'logout'),
              PopupMenuItem(child: Text("Delete account"), value: 'delete'),
            ],
            onSelected: (val) {
              if (val == 'logout') {
                _authController.deconnexion();
                Navigator.pushReplacementNamed(context, '/');
              }
              if (val == 'delete') {
                _authController.supprimerCompte(currentUserId);
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              print(currentUserId);
              Navigator.pushNamed(
                  context,
                  '/personal_expenses',
                  arguments: currentUserId
              ).then((_) => setState(() {}));

            },
            child: Container(
              color: Colors.blue,
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: FutureBuilder<double>(
                future: _statsController.getMonthExpensesAmount(currentUserId),
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      Text("Monthly Expenses (Personal + Groups)", style: TextStyle(color: Colors.white)),
                      Text(
                        "${snapshot.data?.toStringAsFixed(2) ?? 0} €",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, color: Colors.white70, size: 16),
                          SizedBox(width: 5),
                          Text("View personal expenses", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Group>>(
              future: _groupController.getMyGroups(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error : ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No groups yet. Create one !"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Group group = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.group),
                          backgroundColor: Colors.blue[100],
                        ),
                        title: Text(group.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Code : ${group.code}"),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigation vers le détail du groupe
                          Navigator.pushNamed(
                              context,
                              '/group_detail',
                              arguments: {
                                'group': group,
                                'userId': currentUserId
                              }
                          ).then((_) {
                            setState(() {});
                          });
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
        onPressed: () => _showGroupDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("New"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showCreateGroupDialog(context);
                },
                child: Text("Create a group")
            ),
            SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showJoinGroupDialog(context);
                },
                child: Text("Join a group")
            ),
            SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/expense_form', arguments: {
                    'isPerso': true,
                    'payerId': currentUserId});
                },
                child: Text("Personal Expense")
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Create a group"),
        content: TextField(controller: _groupNameCtrl, decoration: InputDecoration(labelText: "Group name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _groupController.createGroup(_groupNameCtrl.text, currentUserId);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: Text("Create"),
          )
        ],
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Join a group"),
        content: TextField(controller: _GroupCodeCtrl, decoration: InputDecoration(labelText: "Group code")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await _groupController.joinGroup(_GroupCodeCtrl.text, currentUserId);
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text("Join"),
          )
        ],
      ),
    );
  }
}