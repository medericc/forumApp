class Reply {
  final int id;
  final int userId;
  final String username; // Ajout du champ username
  final String description;
  final DateTime createdAt;

  Reply({
    required this.id,
    required this.userId,
    required this.username, // Ajout du champ username au constructeur
    required this.description,
    required this.createdAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    // Essayer de parser la date, sinon renvoyer une date par défaut
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at']);
    } catch (e) {
      print("Error parsing date: ${json['created_at']}");
      createdAt = DateTime.now(); // Ou toute autre valeur par défaut
    }

    return Reply(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'], // Extraction du username depuis le JSON
      description: json['description'],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username, // Ajout du champ username au JSON
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
