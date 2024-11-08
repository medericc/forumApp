import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/topic.dart';
import '../models/reply.dart' as reply_model;
import '../services/api_services.dart';
import '../services/auth.service.dart';

class TopicDetailScreen extends StatefulWidget {
  final Topic topic;

  TopicDetailScreen({required this.topic});

  @override
  _TopicDetailScreenState createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  late TextEditingController _replyController;
  late Future<List<reply_model.Reply>> futureReplies;
  bool isLoggedIn = false;
  String? userRole; // Variable to store user role
  String? userId; // Variable to store user ID


@override
void initState() {
  super.initState();
  _replyController = TextEditingController();
  futureReplies = ApiService().getReplies(widget.topic.id);
  _checkLoginStatus();
}

void _checkLoginStatus() async {
  bool loggedIn = await AuthService().isLoggedIn;
  String? role = await AuthService().getRole(); // Assuming you have this method
  String? id = await AuthService().getUserId(); // Get the current user's ID
  setState(() {
    isLoggedIn = loggedIn;
    userRole = role;
    userId = id;
  });
}


  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _addReply() async {
    if (_replyController.text.trim().isEmpty) return;

    if (!isLoggedIn) {
      _showLoginDialog(context);
      return;
    }

    String? userId = await AuthService().getUserId(); 

    if (userId != null) {
      int userIdInt = int.parse(userId);

      try {
        await ApiService().addReply(widget.topic.id, userIdInt, _replyController.text);
        setState(() {
          futureReplies = ApiService().getReplies(widget.topic.id);
        });
        _replyController.clear();
      } catch (error) {
        print('Failed to add reply: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add reply. Please try again.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: Text('User ID is null. Please try again.'),
      ));
    }
  }

  void _showLoginDialog(BuildContext context) {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Connexion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                String? token = await AuthService().login(
                  _usernameController.text,
                  _passwordController.text,
                );
                if (token != null) {
                  setState(() {
                    isLoggedIn = true;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Échec de la connexion. Veuillez réessayer.'),
                  ));
                }
              },
              child: Text('Connexion'),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterDialog(BuildContext context) {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController(); // Nouveau contrôleur pour le code admin

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Inscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nom d\'utilisateur',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
              ),
              obscureText: true,
            ),
            TextField(  // Champ pour entrer le code d'administration
              controller: _adminCodeController,
              decoration: InputDecoration(
                labelText: 'Code d\'administration (optionnel)',
              ),
              obscureText: true,  // Cache le texte comme un mot de passe
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool success = await _registerUser(
                _usernameController.text,
                _passwordController.text,
                _adminCodeController.text,  // Passe le code admin à la fonction d'inscription
              );
              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Inscription réussie. Veuillez vous connecter.'),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Échec de l\'inscription. Veuillez réessayer.'),
                ));
              }
            },
            child: Text('Inscription'),
          ),
        ],
      );
    },
  );
}

Future<bool> _registerUser(String username, String password, String adminCode) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:5000/api/auth/register'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'password': password,
      'admin_code': adminCode,  // Ajoute le code admin dans la requête JSON
    }),
  );

  return response.statusCode == 201;
}
 Future<void> _likeReply(int replyId) async {
    if (!isLoggedIn) {
      _showLoginDialog(context); // Demande de connexion si non connecté
      return;
    }

    try {
      await ApiService().addReplyLike(replyId, int.parse(userId!));
      setState(() {
        futureReplies = ApiService().getReplies(widget.topic.id);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'ajout du like. Veuillez réessayer.'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        actions: [
          isLoggedIn
              ? IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    AuthService().logout();
                    setState(() {
                      isLoggedIn = false;
                    });
                  },
                )
              : Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.login),
                      onPressed: () {
                        _showLoginDialog(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () {
                        _showRegisterDialog(context);
                      },
                    ),
                  ],
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            '${widget.topic.username ?? "Unknown"}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
           
           SizedBox(height: 4.0),
           
           Text( widget.topic.description),
 SizedBox(height: 5.0),
            Text('Date: ${widget.topic.createdAt}'),
            SizedBox(height: 32.0),
   Expanded(
  child: FutureBuilder<List<reply_model.Reply>>(
    future: futureReplies,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Erreur: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('Pas de réponses pour le moment'));
        } else {
          List<reply_model.Reply> replies = snapshot.data!;
          return ListView.builder(
            itemCount: replies.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    '${replies[index].username}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 11.0),
                      Text(replies[index].description),
                      Text('Posté le ${replies[index].createdAt}'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            color: Colors.blue,
                            onPressed: () => _likeReply(replies[index].id),
                          ),
                          Text('${replies[index].likeCount}'), // Affiche le nombre de likes
                        ],
                      ),
                      FutureBuilder<String?>(
                        future: AuthService().getUserId(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Erreur lors de la vérification de l\'utilisateur');
                          } else if (snapshot.hasData) {
                            String currentUserId = snapshot.data!;
                            // Vérifie si l'utilisateur est connecté et a les droits pour supprimer la réponse
                            if (isLoggedIn && 
                               (userRole == 'admin' || replies[index].userId.toString() == currentUserId)) {
                              return TextButton(
                                onPressed: () async {
                                  try {
                                    await ApiService().deleteReply(
                                      replies[index].id,
                                      replies[index].userId,
                                      userRole!,
                                    );
                                    setState(() {
                                      futureReplies = ApiService().getReplies(widget.topic.id);
                                    });
                                  } catch (error) {
                                    print('Erreur lors de la suppression de la réponse: $error');
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Erreur lors de la suppression. Réessayez.'),
                                    ));
                                  }
                                },
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      } else {
        return const Center(child: Text('Pas de réponses pour le moment'));
      }
    },
  ),
),
const SizedBox(height: 16.0),
TextField(
  controller: _replyController,
  decoration: const InputDecoration(
    labelText: 'Votre réponse',
    border: OutlineInputBorder(),
  ),
  maxLines: 3,
),
const SizedBox(height: 16.0),
ElevatedButton(
  onPressed: _addReply,
  child: const Text('Envoyer'),
),

          ],
        ),
      ),
    );
  }
}
