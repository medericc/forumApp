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
  String? userRole;
  TextEditingController searchController = TextEditingController();
  List<Topic> allTopics = []; // Pour stocker tous les sujets non filtrés
  List<Topic> filteredTopics = []; // Pour stocker les sujets filtrés

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    
    futureTopics = ApiService().getTopicsByCategory(widget.categoryId).then((topics) {
      allTopics = topics ?? [];
      filteredTopics = allTopics;
      return allTopics;
    });
  }

  void _checkLoginStatus() async {
    isLoggedIn = await AuthService().isLoggedIn;
    userId = await AuthService().getUserId();
    userRole = await AuthService().getRole();
    setState(() {});
  }

void _deleteTopic(int topicId, int topicOwnerId) async {
  if (userId != null && userRole != null) {
    try {
      if (userRole == 'admin' || userRole == 'moderator' || int.parse(userId!) == topicOwnerId) {
        await ApiService().deleteTopic(topicId, int.parse(userId!), userRole!);
        
        setState(() {
          allTopics.removeWhere((topic) => topic.id == topicId);
          filteredTopics.removeWhere((topic) => topic.id == topicId);
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


  // Fonction de filtre pour mettre à jour les sujets en fonction de la recherche
  void _filterTopics(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTopics = allTopics;
      } else {
        filteredTopics = allTopics
            .where((topic) => topic.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des sujets'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterTopics,
              decoration: InputDecoration(
                labelText: 'Rechercher un sujet',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Topic>>(
              future: futureTopics,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: filteredTopics.length,
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];
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
                                  (userRole == 'admin' ||
                                      userRole == 'moderator' ||
                                      topic.userId.toString() == userId)
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteTopic(topic.id, topic.userId),
                                )
                              : null,
                          onTap: () {
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
          ),
        ],
      ),
    );
  }
}
