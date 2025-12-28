import 'package:flutter/material.dart';
import 'package:projet_budget/views/personal_expense_screen.dart';
import 'package:sqflite/sqflite.dart';

import 'views/auth_screens.dart'; // LoginScreen et RegisterScreen
import 'views/home_screen.dart';
import 'views/group_detail_screen.dart';
import 'views/expense_form_screen.dart';

import 'models/group.dart';
import 'models/expense.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projet Budget',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },

      onGenerateRoute: (settings) {

        if (settings.name == '/group_detail') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (context) => GroupDetailScreen(
              group: args['group'],
              currentUserId: args['userId'],
            ),
          );
        }

        if (settings.name == '/personal_expenses') {
          final userId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => PersonalExpenseScreen(userId: userId),
          );
        }

        if (settings.name == '/expense_form') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};

          return MaterialPageRoute(
            builder: (context) => ExpenseFormScreen(
              groupId: args['groupId'],
              existingExpense: args['existingExpense'],
              payerId: args['payerId'],
            ),
          );
        }
        return null;
      },
    );
  }
}