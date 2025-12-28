import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../services/database_service.dart';
import '../models/user.dart';

class AuthController {

  Future<void> inscription(String pseudo, String mail, String password) async {

    final userExists = await DatabaseService().userExists(mail);

    if (userExists) {
      throw Exception("Email address already present in the database");
    }

    // Hash
    String passwordHash = _hashPassword(password);
    final newUser = User(
      id: 0,
      username: pseudo,
      email: mail,
      password: passwordHash,
      createdAt: DateTime.now(),
    );

    await DatabaseService().insertUser(newUser);
    print("SUCCESS: User inserted !");
  }

  Future<User> connexion(String mail, String password) async {
    String inputHash = _hashPassword(password);

    final user = await DatabaseService().getUserByCredentials(mail, inputHash);

    if (user == null) {
      throw Exception("Invalid credentials");
    }

    return user;
  }

  Future<void> deconnexion() async {
  }

  Future<void> supprimerCompte(int userId) async {
    await DatabaseService().deleteUser(userId);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}