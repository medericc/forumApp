import 'Reply.dart';
class Topic {
  final int id;
  final String title;
  final String description;
  final int userId; 
  final String username;  // Add this field to store the username
  final String createdAt; 
  final List<Reply> replies;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.username,  // Include the username in the constructor
    required this.createdAt,
    required this.replies,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    var list = json['replies'] as List?;
    List<Reply> repliesList = list != null 
        ? list.map((i) => Reply.fromJson(i)).toList() 
        : [];

    return Topic(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['user_id'],
      username: json['username'],  // Map the username from JSON
      createdAt: json['created_at'],
      replies: repliesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'user_id': userId,
      'username': username,  // Include the username in the JSON conversion
      'created_at': createdAt,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}
