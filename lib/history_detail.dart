import 'package:flutter/material.dart';
import 'history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryDetailPage extends StatelessWidget {
  final Commande commande;

  HistoryDetailPage({required this.commande});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de la commande',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, // Couleur de la flèche de retour
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date de la commande : ${commande.date}'),
              SizedBox(height: 8.0),
              Text('Total de la commande : ${commande.total} €'),
              SizedBox(height: 16.0),
              Text('Détails de la commande -', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              _buildDetailsList(commande),
              SizedBox(height: 16.0),
              _buildCancelButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsList(Commande commande) {
    return Column(
      children: commande.produits.asMap().entries.map((entry) {
        int index = entry.key;
        String produit = entry.value;
        String location = commande.location[index];
        double prix = commande.prix[index];
        String imageUrl = commande.imageUrl[index];

        return Container(
          height: 300,
          child: Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Produit : $produit'),
                  SizedBox(height: 12.0),
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 12.0),
                  Text('Location : $location'),
                  SizedBox(height: 12.0),
                  Text('Prix : $prix €'),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _showConfirmationDialog(context);
        },
        child: Text('Annuler commande'),
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
          onPrimary: Colors.white,
          padding: EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer annulation'),
          content: Text('Voulez-vous vraiment annuler cette commande?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                annulerCommande(context, commande);
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void annulerCommande(BuildContext context, Commande commande) async {
    // Ajoutez ici la logique pour annuler la commande
    // Supprimez la commande de la base de données ou effectuez d'autres opérations nécessaires

    // Supprimer la commande de la base de données
    CollectionReference commandesCollection = FirebaseFirestore.instance.collection('commandes');
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await commandesCollection
        .where('date', isEqualTo: commande.date)
        .get() as QuerySnapshot<Map<String, dynamic>>;

    if (querySnapshot.docs.isNotEmpty) {
      // Supprimez le document de la commande
      await commandesCollection.doc(querySnapshot.docs.first.id).delete();
    }

    // Affichez un SnackBar pour indiquer que la commande a été annulée
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande annulée avec succès !'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    // Une fois la commande annulée, retournez à la page des commandes
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }
}
