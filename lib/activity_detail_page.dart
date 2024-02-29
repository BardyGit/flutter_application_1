import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_page.dart';

class ActivityDetailPage extends StatefulWidget {
  final Activity activity;

  ActivityDetailPage(this.activity);

  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de l\'activité',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(
        color: Colors.white, // Couleur de la flèche de retour
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  image: NetworkImage(widget.activity.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Informations sur l'activité
            Text(
              widget.activity.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Lieu : ${widget.activity.location}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Prix : ${widget.activity.prix} €',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Catégorie : ${widget.activity.categorie}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Personne requise : ${widget.activity.personne} minimum',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await addToCart(widget.activity);
                _showAddToCartMessage(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                padding: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Ajouter au panier'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart(Activity activity) async {
    try {
      // Ajout de l'activité au panier dans Firestore
      await FirebaseFirestore.instance.collection('panier').add({
        'title': activity.title,
        'location': activity.location,
        'prix': activity.prix,
        'imageUrl': activity.imageUrl,
      });
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
    }
  }

  void _showAddToCartMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Activité ajoutée au panier avec succès!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
