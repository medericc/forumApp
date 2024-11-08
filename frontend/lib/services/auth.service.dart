import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:5000/api/auth';

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Utilisation de JwtDecoder pour décoder le JWT
        Map<String, dynamic> decodedToken = JwtDecoder.decode(responseData['token']);
        String userId = decodedToken['user_id'].toString();
        String role = decodedToken['role']; // Récupérez le rôle du token

        print('User ID on login: $userId');
        print('User role on login: $role');

        // Sauvegarde du token et des informations utilisateur
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['token']);
        await prefs.setString('user_id', userId);
        await prefs.setString('role', role); // Sauvegardez également le rôle

        return responseData['token'];
      } else {
        print('Échec de la connexion avec le code : ${response.statusCode}');
        print('Contenu de la réponse : ${response.body}');
        return null;
      }
    } catch (error) {
      print('Une erreur est survenue lors de la connexion : $error');
      return null;
    }
  }

  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode({'username': username, 'password': password}),
    );

    return response.statusCode == 201;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('role'); // Supprimez également le rôle
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<bool> get isLoggedIn async {
    String? token = await getToken();
    return token != null;
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role'); // Récupérez le rôle stocké
  }
}
