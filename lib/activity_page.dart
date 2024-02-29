import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'panier.dart';
import 'profile.dart';
import 'activity_detail_page.dart';
import 'history.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ActivitiesPage(),
      theme: ThemeData(
        primaryColor: Colors.cyan,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan),
      ),
    );
  }
}

class ActivitiesPage extends StatefulWidget {
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activités',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: ActivityList(),
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
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PanierPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryPage()),
            );
          } else if (index == 3) {
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

class ActivityList extends StatefulWidget {
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> with TickerProviderStateMixin {
  List<String> categories = ['Tous','Favoris'];
  String selectedCategory = 'Tous';
  bool isFavoritesTabActive = false;

  @override
  void initState() {
    super.initState();
    getActivityCategories();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: FutureBuilder<List<Activity>>(
              future: getActivitiesFromDatabase(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else {
                  List<Activity> activities = snapshot.data ?? [];
                  List<Activity> filteredActivities = [];

                  if (selectedCategory == 'Tous') {
                    filteredActivities = activities;
                  } else if (selectedCategory == 'Favoris') {
                    FavoritesProvider favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
                    filteredActivities = activities = activities.where((activity) => favoritesProvider.favorites.contains(activity.id)).toList();
                    if (filteredActivities.isEmpty) {
                      return Center(
                      child: Text('Aucun favori trouvé.'),
                      );
                    }
                  } else {
                    filteredActivities = activities.where((activity) => activity.categorie == selectedCategory).toList();
                  }

                  return ListView.builder(
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4.0,
                        margin: EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ActivityDetailPage(filteredActivities[index])),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                filteredActivities[index].imageUrl,
                                width: double.infinity,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          filteredActivities[index].title,
                                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          '${filteredActivities[index].location} - ${filteredActivities[index].prix} €',
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          'Catégorie : ${filteredActivities[index].categorie}',
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                    _buildAddToCartAndFavoritesButton(context, filteredActivities[index]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartAndFavoritesButton(BuildContext context, Activity activity) {
    return Row(
      children: [
        AddToFavoritesButton(activity: activity),
        IconButton(
          icon: Icon(Icons.shopping_cart, color: Colors.green),
          onPressed: () async {
            await addToCart(activity);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Activité ajoutée au panier avec succès !'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> addToCart(Activity activity) async {
    try {
      await FirebaseFirestore.instance.collection('panier').add({
        'title': activity.title,
        'location': activity.location,
        'prix': activity.prix,
        'imageUrl': activity.imageUrl,
      });
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      throw e;
    }
  }

  Widget _buildTabBar() {
  return TabBar(
    tabs: categories.map((category) => Tab(text: category)).toList(),
    onTap: (index) {
      setState(() {
        selectedCategory = categories[index];
         isFavoritesTabActive = (selectedCategory == 'Favoris');
      });
    },
  );
}

  Future<void> getActivityCategories() async {
  CollectionReference activitiesCollection = FirebaseFirestore.instance.collection('activities');

  try {
    QuerySnapshot<Map<String, dynamic>> categoriesSnapshot = await activitiesCollection.get() as QuerySnapshot<Map<String, dynamic>>;

    Set<String> fetchedCategories = {'Tous','Favoris'};

    for (QueryDocumentSnapshot<Map<String, dynamic>> activityDoc in categoriesSnapshot.docs) {
      String category = activityDoc['categorie'];
      fetchedCategories.add(category);
    }

    setState(() {
      categories = fetchedCategories.toList();
    });
  } catch (e) {
    print('Erreur lors de la récupération des catégories depuis la base de données: $e');
    throw e;
  }
}

Future<List<Activity>> getActivitiesFromDatabase() async {
  CollectionReference activitiesCollection = FirebaseFirestore.instance.collection('activities');

  try {
    QuerySnapshot<Map<String, dynamic>> activitiesSnapshot =
        await activitiesCollection.get() as QuerySnapshot<Map<String, dynamic>>;

    List<Activity> activities = activitiesSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()!;
      return Activity(
        id : doc.id,
        title: data['title'],
        location: data['location'],
        prix: data['prix'],
        imageUrl: data['imageUrl'],
        categorie: data['categorie'],
        personne: data['personne'],
      );
    }).toList();

    FavoritesProvider favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    
    if (selectedCategory == 'Favoris') {
      // Si l'onglet "Favoris" est sélectionné, retourne uniquement les activités marquées comme favoris
      activities = activities.where((activity) => favoritesProvider.favorites.contains(activity.id)).toList();
    } else if (selectedCategory != 'Tous') {
      // Filtre les activités par la catégorie sélectionnée
      activities = activities.where((activity) => activity.categorie == selectedCategory).toList();
    }

    return activities;
  } catch (e) {
    print('Erreur lors de la récupération des activités depuis la base de données: $e');
    throw e;
  }
}
}

class AddToFavoritesButton extends StatelessWidget {
  final Activity activity;

  AddToFavoritesButton({required this.activity});

  @override
  Widget build(BuildContext context) {
    FavoritesProvider favoritesProvider = Provider.of<FavoritesProvider>(context);

    return IconButton(
      icon: Icon(
        favoritesProvider.favorites.contains(activity.id) ? Icons.favorite : Icons.favorite_border,
        color: Colors.red,
      ),
      onPressed: () {
        favoritesProvider.toggleFavorite(activity.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              favoritesProvider.favorites.contains(activity.id)
                  ? 'Activité ajoutée aux favoris !'
                  : 'Activité retirée des favoris !',
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }
}

class Activity {
  final String id;
  final String title;
  final String location;
  final double prix;
  final String imageUrl;
  final String categorie;
  final int personne;

  Activity({
    required this.id,
    required this.title,
    required this.location,
    required this.prix,
    required this.imageUrl,
    required this.categorie,
    required this.personne,
  });
}

class FavoritesProvider extends ChangeNotifier {
  Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  void toggleFavorite(String activityId) {
    if (_favorites.contains(activityId)) {
      _favorites.remove(activityId);
    } else {
      _favorites.add(activityId);
    }
    notifyListeners();
  }
}


