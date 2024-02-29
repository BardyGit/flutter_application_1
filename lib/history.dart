import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';
import 'panier.dart';
import 'activity_page.dart';
import 'history_detail.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique des commandes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: CommandesList(),
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
          if(index == 2){
            // actualiser la page
            setState(() {});
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }
        },
      ),
    );
  }
}

class CommandesList extends StatelessWidget {
 @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Commande>>(
      future: getCommandesFromDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else {
          List<Commande> commandes = snapshot.data ?? [];

          if (commandes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Aucune commande trouvée.'),
                  SizedBox(height: 8.0),
                  InkWell(
                    onTap: () {
                      // Naviguer vers la page du panier
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PanierPage(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
                        Text('Panier', style: TextStyle(color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: commandes.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 4.0,
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Commande du ${commandes[index].date}'),
                  subtitle: Text('Total: ${commandes[index].total} €'),
                  onTap: () {
                    // Naviguer vers la page de détail de la commande
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailPage(commande: commandes[index]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<List<Commande>> getCommandesFromDatabase() async {
    CollectionReference commandesCollection = FirebaseFirestore.instance.collection('commandes');

    try {
      QuerySnapshot<Map<String, dynamic>> commandesSnapshot = await commandesCollection.get() as QuerySnapshot<Map<String, dynamic>>;

      List<Commande> commandes = commandesSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        return Commande(
          date: (data['date'] as Timestamp).toDate(),
          total: (data['prix'] as List).map((e) => e as double).fold(0, (a, b) => a + b),
          produits: List<String>.from(data['produits']),
          imageUrl: List<String>.from(data['imageUrl']),
          location: List<String>.from(data['location']),
          prix: List<double>.from(data['prix']),
        );
      }).toList();

      return commandes;
    } catch (e) {
      print('Erreur lors de la récupération des commandes depuis la base de données: $e');
      throw e;
    }
  }
}

class Commande {
  final DateTime date;
  final double total;
  final List<String> produits;
  final List<String> imageUrl;
  final List<String> location;
  final List<double> prix;

  Commande({
    required this.date,
    required this.total,
    required this.produits,
    required this.imageUrl,
    required this.location,
    required this.prix,
  });
}
