// lib/widgets/post_item.dart

import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  final String author;
  final String content;

  PostItem({
    required this.author,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(author),
      subtitle: Text(content),
    );
  }
}
