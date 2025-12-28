import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Interface graphique: L'écran affiche deux champs de saisie pour l'identifiant et le mot de passe (Page 8)
    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
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
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true
            ),
            SizedBox(height: 20),
            // Interface graphique: bouton de validation pour accéder à l'application (Page 8)
            ElevatedButton(
              onPressed: () async {
                try {
                  // 1. On récupère l'utilisateur complet (avec son ID)
                  final user = await _authController.connexion(_mailController.text, _passController.text);

                  // 2. On passe son ID en argument vers l'écran d'accueil
                  Navigator.pushReplacementNamed(
                      context,
                      '/home',
                      arguments: user.id // <--- C'est ici qu'on transmet la "session"
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: Text("Se connecter"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text("Créer un compte"),
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

  // Dans un StatefulWidget, on initialise les controllers ici pour qu'ils ne soient pas perdus
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
    // On nettoie la mémoire quand l'écran est fermé
    _pseudo.dispose();
    _mail.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _pseudo, decoration: InputDecoration(labelText: 'Pseudo')),
            TextField(controller: _mail, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _pass, decoration: InputDecoration(labelText: 'Mot de passe'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // On empêche d'envoyer si les champs sont vides
                  if (_mail.text.isEmpty) return;

                  await _authController.inscription(_pseudo.text.trim(), _mail.text.trim(), _pass.text);

                  // Si succès
                  if (mounted) { // Vérifie que l'écran est toujours là
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Compte créé !")));
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}