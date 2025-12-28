import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../models/expense.dart';
import '../models/expense_participant.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'budget_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Required to enable foreign key constraints (Cascades)
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Table creation based on the technical analysis
  Future<void> _createDB(Database db, int version) async {
    // 1. User Table
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username VARCHAR(50) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE, 
        password VARCHAR(255) NOT NULL,
        created_at DATETIME NOT NULL
      )
    ''');

    // 2. Group Table
    await db.execute('''
      CREATE TABLE app_group (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(100) NOT NULL,
        code VARCHAR(6) NOT NULL UNIQUE,
        created_at DATETIME NOT NULL,
        owner_id INTEGER NOT NULL,
        FOREIGN KEY (owner_id) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');

    // 3. GroupMember Table
    await db.execute('''
      CREATE TABLE group_member (
        group_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        joined_at DATETIME NOT NULL,
        PRIMARY KEY (group_id, user_id),
        FOREIGN KEY (group_id) REFERENCES app_group (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');

    // 4. Category Table
    await db.execute('''
      CREATE TABLE category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(50) NOT NULL
      )
    ''');

    // Default categories insertion
    await db.rawInsert("INSERT INTO category (name) VALUES ('Food')");
    await db.rawInsert("INSERT INTO category (name) VALUES ('Housing')");
    await db.rawInsert("INSERT INTO category (name) VALUES ('Transportation')");
    await db.rawInsert("INSERT INTO category (name) VALUES ('Hobby')");

    // 5. Expense Table
    await db.execute('''
      CREATE TABLE expense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title VARCHAR(255) NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        expense_date DATE NOT NULL,
        created_at DATETIME NOT NULL,
        payer_id INTEGER NOT NULL,
        group_id INTEGER,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (payer_id) REFERENCES user (id) ON DELETE CASCADE,
        FOREIGN KEY (group_id) REFERENCES app_group (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES category (id)
      )
    ''');

    // 6. ExpenseParticipant Table
    await db.execute('''
      CREATE TABLE expense_participant (
        expense_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        PRIMARY KEY (expense_id, user_id),
        FOREIGN KEY (expense_id) REFERENCES expense (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // USERS METHOD
  // ---------------------------------------------------------------------------

  Future<void> insertUser(User user) async {
    final db = await database;
    var map = user.toMap();
    map.remove('id');
    await db.insert('user', map);
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    final res = await db.query('user', where: 'email = ?', whereArgs: [email]);
    return res.isNotEmpty;
  }

  Future<User?> getUserByCredentials(String email, String passwordHash) async {
    final db = await database;
    final res = await db.query('user', where: 'email = ? AND password = ?', whereArgs: [email, passwordHash]);
    return res.isNotEmpty ? User.fromMap(res.first) : null;
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<User>> getGroupMembers(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT u.* FROM user u
      INNER JOIN group_member gm ON u.id = gm.user_id
      WHERE gm.group_id = ?
    ''', [groupId]);
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<void> createGroupWithMember(Group group, int userId) async {
    final db = await database;
    await db.transaction((txn) async {
      var groupMap = group.toMap();
      groupMap.remove('id');
      int newGroupId = await txn.insert('app_group', groupMap);
      await txn.insert('group_member', {
        'group_id': newGroupId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<Group?> getGroupByCode(String code) async {
    final db = await database;
    final res = await db.query('app_group', where: 'code = ?', whereArgs: [code]);
    return res.isNotEmpty ? Group.fromMap(res.first) : null;
  }

  Future<Group> getGroupById(int id) async {
    final db = await database;
    final res = await db.query('app_group', where: 'id = ?', whereArgs: [id]);
    return Group.fromMap(res.first);
  }

  Future<void> insertMember(GroupMember member) async {
    final db = await database;
    await db.insert('group_member', member.toMap());
  }

  Future<void> removeMember(int groupId, int userId) async {
    final db = await database;
    await db.delete('group_member', where: 'group_id = ? AND user_id = ?', whereArgs: [groupId, userId]);
  }

  Future<void> deleteGroup(int groupId) async {
    final db = await database;
    await db.delete('app_group', where: 'id = ?', whereArgs: [groupId]);
  }

  Future<List<Group>> getUserGroups(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT g.* FROM app_group g
      INNER JOIN group_member gm ON g.id = gm.group_id
      WHERE gm.user_id = ?
      ORDER BY g.created_at DESC
    ''', [userId]);
    return List.generate(maps.length, (i) => Group.fromMap(maps[i]));
  }

  Future<void> updateGroupName(int groupId, String newName) async {
    final db = await database;
    await db.update('app_group', {'name': newName}, where: 'id = ?', whereArgs: [groupId]);
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    var map = expense.toMap();
    map.remove('id');
    return await db.insert('expense', map);
  }

  Future<void> insertParticipant(ExpenseParticipant part) async {
    final db = await database;
    await db.insert('expense_participant', part.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await database;
    await db.update('expense', expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expense', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getExpensesByGroup(int groupId) async {
    final db = await database;
    final res = await db.query('expense', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'created_at DESC');
    return res.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> getPersonalExpenses(int userId) async {
    final db = await database;
    final res = await db.query('expense', where: 'payer_id = ? AND group_id IS NULL', whereArgs: [userId], orderBy: 'expense_date DESC');
    return res.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> getAllExpensesForUser(int userId) async {
    final db = await database;
    final res = await db.query('expense', where: 'payer_id = ?', whereArgs: [userId]);
    return res.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<int>> getParticipantsForExpense(int expenseId) async {
    final db = await database;
    final res = await db.query('expense_participant', columns: ['user_id'], where: 'expense_id = ?', whereArgs: [expenseId]);
    return res.map((row) => row['user_id'] as int).toList();
  }
}