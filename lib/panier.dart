import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_page.dart';
import 'profile.dart';
import 'history.dart';

class PanierPage extends StatefulWidget {
  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Panier',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false, // Masquer le bouton de retour arrière
      ),
      body: PanierList(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
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
      currentIndex: 1, // L'index pour marquer la page du panier comme active
      selectedItemColor: Theme.of(context).primaryColor, // Couleur de l'élément sélectionné
      unselectedItemColor: Colors.grey,
      onTap: (int index) {
        // Naviguer vers la page correspondante en fonction de l'élément sélectionné
        if (index == 0) {
          // Naviguer vers la page des activités
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ActivitiesPage()),
          );
        } else if (index == 2) {
          // Naviguer vers la page de l'historique des commandes
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HistoryPage()),
          );
        }
        else if (index == 3) {
          // Naviguer vers la page du profil
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        }
      },
    );
  }
}

class PanierList extends StatefulWidget {
  @override
  _PanierListState createState() => _PanierListState();
}

class _PanierListState extends State<PanierList> {
  String removeMessage = '';
  String commandeMessage = '';

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    return FutureBuilder<List<Activity>>(
      future: getPanierFromDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else {
          List<Activity> panier = snapshot.data ?? [];
          double totalPanier = panier.map((activity) => activity.prix).fold(0, (a, b) => a + b);

          return Column(
            children: [
              Expanded(
                child: panier.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Le panier est vide. Ajoutez des activités!'),
                            SizedBox(height: 8.0),
                            InkWell(
                              onTap: () {
                                // Naviguer vers la page des activités
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActivitiesPage(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
                                  Text('Activités', style: TextStyle(color: Theme.of(context).primaryColor)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: panier.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4.0,
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              leading: Image.network(
                                panier[index].imageUrl,
                                width: 80.0,
                                height: 80.0,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                panier[index].title,
                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${panier[index].location} - ${panier[index].prix} €'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  removeFromPanier(panier[index]);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (panier.isNotEmpty)
                // Affichez le total du prix du panier
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total du panier : $totalPanier €',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              // Ajoutez le bouton "Passer Commande" seulement si le panier n'est pas vide
              if (panier.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Passer commande'),
                ),
            ],
          );
        }
      },
    );
  }

  Future<List<Activity>> getPanierFromDatabase() async {
    CollectionReference panierCollection = FirebaseFirestore.instance.collection('panier');

    try {
      QuerySnapshot<Map<String, dynamic>> panierSnapshot = await panierCollection.get() as QuerySnapshot<Map<String, dynamic>>;

      List<Activity> panier = panierSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;
        return Activity(
          title: data['title'],
          location: data['location'],
          prix: data['prix'],
          imageUrl: data['imageUrl'],
        );
      }).toList();

      return panier;
    } catch (e) {
      print('Erreur lors de la récupération du panier depuis la base de données: $e');
      throw e;
    }
  }

  void removeFromPanier(Activity activity) async {
    CollectionReference panierCollection = FirebaseFirestore.instance.collection('panier');

    try {
      // Recherchez le document correspondant à l'activité dans le panier
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await panierCollection
          .where('title', isEqualTo: activity.title)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      if (querySnapshot.docs.isNotEmpty) {
        // Supprimez le document du panier
        await panierCollection.doc(querySnapshot.docs.first.id).delete();
      }

      // Utilisez setState pour mettre à jour l'état
      setState(() {
        removeMessage = 'Activité retirée du panier avec succès!';
      });

      // Affichez le message de suppression avec un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(removeMessage),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('Erreur lors de la suppression de l\'activité du panier: $e');
      throw e;
    }
  }

  Future<void> showConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la commande'),
          content: Text('Voulez-vous vraiment passer cette commande?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await passerCommande();
                Navigator.of(context).pop();
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> passerCommande() async {
    List<Activity> panier = await getPanierFromDatabase();
    double totalPanier = panier.map((activity) => activity.prix).fold(0, (a, b) => a + b);

    if (panier.isNotEmpty) {
      CollectionReference commandesCollection = FirebaseFirestore.instance.collection('commandes');
      await commandesCollection.add({
        'date': DateTime.now(),
        'produits': panier.map((activity) => activity.title).toList(),
        'location': panier.map((activity) => activity.location).toList(),
        'prix': panier.map((activity) => activity.prix).toList(),
        'imageUrl': panier.map((activity) => activity.imageUrl).toList(),
        'total': totalPanier,
      });

      await viderPanier(); 
    }
  }

  Future<void> viderPanier() async {

    CollectionReference panierCollection = FirebaseFirestore.instance.collection('panier');
    await panierCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    // Utilisez setState pour mettre à jour l'état
      setState(() {
        commandeMessage = 'Commande effectuée avec succès !';
      });

      // Affichez le message de suppression avec un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(commandeMessage),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
  }
}

class Activity {
  final String title;
  final String location;
  final double prix;
  final String imageUrl;

  Activity({
    required this.title,
    required this.location,
    required this.prix,
    required this.imageUrl,
  });
}
