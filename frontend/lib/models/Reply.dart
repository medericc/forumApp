class Reply {
  final int id;
  final int userId;
  final String username;
  final String description;
  final DateTime createdAt;
  final int likeCount; // Ajout du champ likeCount

  Reply({
    required this.id,
    required this.userId,
    required this.username,
    required this.description,
    required this.createdAt,
    required this.likeCount, // Ajout du champ likeCount au constructeur
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at']);
    } catch (e) {
      createdAt = DateTime.now();
    }

    return Reply(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      description: json['description'],
      createdAt: createdAt,
      likeCount: json['like_count'] ?? 0, // Extraire le likeCount depuis le JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'like_count': likeCount, // Inclure le champ likeCount dans le JSON
    };
  }
}
