import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/category.dart';
import '../models/topic.dart';
import '../models/reply.dart' as reply_model;
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000'; 

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => User.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Category.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Topic>> getTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/topics'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Topic.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load topics');
    }
  }

  Future<List<Topic>> getTopicsByCategory(int categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/categories/$categoryId/topics'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Topic.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load topics for category $categoryId');
    }
  }

Future<List<reply_model.Reply>> getReplies(int topicId) async {
  final response = await http.get(Uri.parse('$baseUrl/replies/$topicId'));  // Correct endpoint
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => reply_model.Reply.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load replies');
  }
}



Future<void> addReply(int topicId, int userId, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reply'),  // Changement de 'replies' à 'reply'
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'topic_id': topicId,
        'user_id': userId,
        'description': description,  
      }),
    );

    if (response.statusCode == 201) {
      print('Reply added successfully!');
    } else {
      print('Failed to add reply: ${response.statusCode}');
      throw Exception('Failed to add reply');
    }
}

Future<void> deleteTopic(int topicId, int userId, String userRole) async {
  print('deleteTopic called with topicId: $topicId, userId: $userId, userRole: $userRole');

  try {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:5000/topics/$topicId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'role': userRole, // Correspond maintenant à la clé attendue côté serveur
      }),
    );

    print('Server response: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Topic deleted successfully!');
    } else {
      print('Failed to delete topic: ${response.statusCode}');
      throw Exception('Failed to delete topic');
    }
  } catch (e) {
    print('Error occurred while deleting topic: $e');
    throw Exception('Error occurred while deleting topic');
  }
}


  // Méthode pour supprimer une réponse
Future<void> deleteReply(int replyId, int userId, String userRole) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/replies/$replyId'), // Assurez-vous que l'URL est correcte
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'User-Role': userRole,  // Optionnel: Inclure le rôle de l'utilisateur dans les en-têtes si nécessaire
    },
    body: jsonEncode(<String, dynamic>{
      'user_id': userId,       // Inclure l'ID de l'utilisateur dans le corps de la requête
      'user_role': userRole,   // Inclure le rôle de l'utilisateur dans le corps de la requête
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete reply');
  }
}

Future<void> addReplyLike(int replyId, int userId) async {
   try {
    // Étape 1 : Vérifier si le "like" existe déjà avec une requête GET
    final checkResponse = await http.get(
      Uri.parse('$baseUrl/reply_likes/$replyId/$userId'),
    );

    if (checkResponse.statusCode == 200) {
      // Le "like" existe, donc on le retire avec une requête DELETE
      final deleteResponse = await http.delete(
        Uri.parse('$baseUrl/reply_likes/$replyId/$userId'),
      );

      if (deleteResponse.statusCode == 200) {
        print('Like retiré avec succès !');
      } else {
        print('Erreur lors du retrait du like : ${deleteResponse.statusCode}');
        throw Exception('Erreur lors du retrait du like.');
      }
    } else if (checkResponse.statusCode == 404) {
      // Le "like" n'existe pas, donc on l'ajoute avec une requête POST
      final addResponse = await http.post(
        Uri.parse('$baseUrl/reply_likes'),
        body: jsonEncode({'reply_id': replyId, 'user_id': userId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (addResponse.statusCode == 201) {
        print('Like ajouté avec succès !');
      } else {
        print('Erreur lors de l\'ajout du like : ${addResponse.statusCode}');
        throw Exception('Erreur lors de l\'ajout du like.');
      }
    } else {
      print('Erreur lors de la vérification du like : ${checkResponse.statusCode}');
      throw Exception('Erreur lors de la vérification du like.');
    }
  } catch (error) {
    print('Erreur lors de la bascule du like: $error');
    throw Exception('Erreur lors de la bascule du like.');
  }
}
  
}
