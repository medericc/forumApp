class User {
  final int id;
  final String username;
  final String role; // Ajoutez le champ rôle

  User({
    required this.id,
    required this.username,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'], // Assurez-vous de lire le rôle depuis le JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role, // Incluez le rôle dans le JSON
    };
  }
}
