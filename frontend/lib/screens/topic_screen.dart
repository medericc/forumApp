import 'package:flutter/material.dart';
import '../models/topic.dart';
import './treads_screen.dart';
import '../services/api_services.dart';
import '../services/auth.service.dart';

class TopicListScreen extends StatefulWidget {
  final int categoryId;

  TopicListScreen({required this.categoryId});

  @override
  _TopicListScreenState createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  late Future<List<Topic>> futureTopics;
  bool isLoggedIn = false;
  String? userId;
  String? userRole; // Ajoutez une variable pour le rôle de l'utilisateur

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    futureTopics = ApiService().getTopicsByCategory(widget.categoryId).then((topics) {
      return topics ?? []; // Retourner une liste vide si 'topics' est null
    });
  }

  // Méthode pour vérifier si l'utilisateur est connecté
  void _checkLoginStatus() async {
    isLoggedIn = await AuthService().isLoggedIn;
    userId = await AuthService().getUserId();
    userRole = await AuthService().getRole(); // Récupérez le rôle de l'utilisateur
    setState(() {});
  }

  // Méthode pour supprimer un sujet
void _deleteTopic(int topicId, int topicOwnerId) async {
  if (userId != null && userRole != null) {
    try {
      // Vérification de permissions
      if (userRole == 'admin' || userRole == 'moderator' || int.parse(userId!) == topicOwnerId) {
        await ApiService().deleteTopic(topicId, int.parse(userId!), userRole!);
        setState(() {
          futureTopics = ApiService().getTopicsByCategory(widget.categoryId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sujet supprimé avec succès.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vous n\'avez pas les permissions nécessaires pour supprimer ce sujet.'),
        ));
      }
    } catch (error) {
      print('Échec de la suppression du sujet: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Échec de la suppression du sujet. Veuillez réessayer.'),
      ));
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des sujets'),
      ),
      body: FutureBuilder<List<Topic>>(
        future: futureTopics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Topic> topics = snapshot.data!.reversed.toList();
;
            return ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4.0,
                  child: ListTile(
                    title: Text(
                      topic.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Auteur: ${topic.username}'),
                        Text('Date: ${topic.createdAt}'),
                      ],
                    ),
                 trailing: isLoggedIn &&
  (userRole == 'admin' || userRole == 'moderator' || topic.userId.toString() == userId)
    ? IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteTopic(topic.id, topic.userId),
      )
    : null,

                    onTap: () {
                      print('Topic User ID: ${topic.userId}, Logged in User ID: $userId, isLoggedIn: $isLoggedIn');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopicDetailScreen(topic: topic),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Aucun sujet trouvé'));
          }
        },
      ),
    );
  }
}
