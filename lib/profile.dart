import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import 'activity_page.dart';
import 'panier.dart';
import 'history.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _anniversaireController;
  late TextEditingController _adresseController;
  late TextEditingController _codePostalController;
  late TextEditingController _villeController;
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _anniversaireController = TextEditingController();
    _adresseController = TextEditingController();
    _codePostalController = TextEditingController();
    _villeController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firestore.collection('users').doc(_user.uid).get();
      if (userSnapshot.exists) {
        setState(() {
          _anniversaireController.text = userSnapshot.get('anniversaire') ?? '';
          _adresseController.text = userSnapshot.get('adresse') ?? '';
          _codePostalController.text = userSnapshot.get('codePostal') ?? '';
          _villeController.text = userSnapshot.get('ville') ?? '';
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données de l\'utilisateur : $e');
    }
  }

  Future<void> _updateUserData() async {
    try {
      await _firestore.collection('users').doc(_user.uid).update({
        'anniversaire': _anniversaireController.text,
        'adresse': _adresseController.text,
        'codePostal': _codePostalController.text,
        'ville': _villeController.text,
      });

      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text == _confirmPasswordController.text) {
          await _auth.currentUser!.updatePassword(_passwordController.text);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Les mots de passe ne correspondent pas.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Données mises à jour avec succès!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Erreur lors de la mise à jour des données de l\'utilisateur : $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor:Theme.of(context).primaryColor,// Colors.cyan,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserInfo(),
              SizedBox(height: 16.0),
              _buildEditablePasswordField('Mot de passe', Icons.lock, _passwordController, _confirmPasswordController),
              SizedBox(height: 16.0),
              _buildEditableField('Anniversaire', Icons.cake, _anniversaireController),
              _buildEditableField('Adresse', Icons.location_on, _adresseController),
              _buildEditableField('Code Postal', Icons.location_city, _codePostalController, isNumeric: true),
              _buildEditableField('Ville', Icons.location_city, _villeController),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.all(16.0),
                ),
                child: Text('Valider'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.all(16.0),
                ),
                child: Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), 
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivitiesPage()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PanierPage()),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryPage()),
            );
          }
          if (index == 3) {
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour,',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  size: 40,
                ),
                SizedBox(width: 16.0),
                Text(
                  _user.email ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, IconData icon, TextEditingController controller, {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon),
            SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        ),
        SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildEditablePasswordField(String label, IconData icon, TextEditingController passwordController, TextEditingController confirmPasswordController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon),
            SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Nouveau mot de passe',
          ),
        ),
        SizedBox(height: 8.0),
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirmer le mot de passe',
          ),
        ),
        SizedBox(height: 8.0),
      ],
    );
  }
}
