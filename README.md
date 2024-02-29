# Miaged - Application Flutter

Application flutter MIAGED - BARDY Matthias

## User Stories
L'entièreté des US composant le MVP on était réalisé, voici un rapide récapitulatif : 

[MVP] Interface de connexion (US 1) - ✅
- Une page de connexion avec des champs pour le login et le mot de passe.
- Bouton de connexion qui redirige vers la page des activités si les identifiants sont valides.
- Validation des champs avec des messages d'erreur appropriés.

[MVP] Liste des activités (US 2) - ✅
- Page principale avec une liste déroulante des activités.
- Redirection vers le détail au clic
- Récupération depuis la base de données
- Intégration d'une BottomNavigationBar pour la navigation entre les pages Activités, Panier, et Profil.

[MVP] Détail d'une activité (US 3) - ✅
- Page détaillée pour chaque activité avec informations demandées.
- Bouton "Ajouter au panier".
- Retour à la liste des activités depuis la page de détail (flèche de retour).
  
[MVP] Le panier (US 4) - ✅
- Affichage des activités dans le panier avec informations, possibilité de retirer des produits.
- Calcul du total général des activités dans le panier.

[MVP] Profil utilisateur (US 5) - ✅
- Page de profil avec les informations utilisateur récupérées de la base de données.
- Possibilité de modifier le mot de passe (avec confirmation) , l'anniversaire, l'adresse, le code postal (chiffres uniquement), et la ville.
- Bouton de déconnexion.
  
[MVP] Filtrer sur la liste des activités (US 6) - ✅
- TabBar pour filtrer la liste des activités par catégorie.
- Possibilité de filtrer les activités par catégorie.
  
Fonctionnalités supplémentaires (US 7)- ✅
- Ajout facilité au panier depuis la page des activités avec une icône de panier sur chaque activité.
- Liens de navigation facilités lorsque le panier est vide et lors de la commande.
- Système de commande + détail avec historique accessible depuis la BottomNavigationBar (3ème icone).
- Système de favoris sur la page Activités avec ajout et filtrage.
  
## Test
L'application a été testée sur Google Chrome en mode téléphone avec utilisation de Firebase.

Identifiants de connexion :

Login: test@gmail.com
Mot de passe: testtest
