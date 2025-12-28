import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: _mailController,
                decoration: InputDecoration(labelText: 'Email')
            ),
            TextField(
                controller: _passController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await _authController.connexion(_mailController.text, _passController.text);

                  Navigator.pushReplacementNamed(
                      context,
                      '/home',
                      arguments: user.id
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text("Sign in"),
            )
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();

  late TextEditingController _pseudo;
  late TextEditingController _mail;
  late TextEditingController _pass;

  @override
  void initState() {
    super.initState();
    _pseudo = TextEditingController();
    _mail = TextEditingController();
    _pass = TextEditingController();
  }

  @override
  void dispose() {
    _pseudo.dispose();
    _mail.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign in")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _pseudo, decoration: InputDecoration(labelText: 'Username')),
            TextField(controller: _mail, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _pass, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (_mail.text.isEmpty) return;

                  await _authController.inscription(_pseudo.text.trim(), _mail.text.trim(), _pass.text);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account created !")));
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: Text("Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}