import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'activity_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginController.text,
        password: passwordController.text,
      );

      // Utilisateur authentifié avec succès, redirection vers la page des activités
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ActivitiesPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        // L'utilisateur n'existe pas ou le mot de passe est incorrect
        setState(() {
          errorMessage = 'Identifiants incorrects. Veuillez réessayer.';
        });
      } else {
        setState(() {
          errorMessage = 'Une erreur s\'est produite. Veuillez réessayer plus tard.';
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        errorMessage = 'Une erreur s\'est produite. Veuillez réessayer plus tard.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MIAGED',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: loginController,
              decoration: InputDecoration(labelText: 'Login'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Validation des champs
                if (loginController.text.isEmpty || passwordController.text.isEmpty) {
                  return;
                }
                // Réinitialiser le message d'erreur à chaque tentative
                setState(() {
                  errorMessage = '';
                });
                // Authentification avec Firebase
                signInWithEmailAndPassword(context);
              },
              child: Text('Se connecter'),
            ),
            SizedBox(height: 8.0),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
