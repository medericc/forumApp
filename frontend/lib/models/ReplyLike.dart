class ReplyLike {
  final int id;
  final int replyId;
  final int userId;
  final DateTime createdAt;

  ReplyLike({
    required this.id,
    required this.replyId,
    required this.userId,
    required this.createdAt,
  });

  factory ReplyLike.fromJson(Map<String, dynamic> json) {
    return ReplyLike(
      id: json['id'],
      replyId: json['reply_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reply_id': replyId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
