import 'package:flutter/material.dart';
import 'topic.dart';  // Utilisez un chemin relatif si les fichiers sont dans le même dossier


class TopicDetailScreen extends StatelessWidget {
  final Topic topic;

  TopicDetailScreen({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text('Auteur: ${topic.userId}'),
            Text('Date: ${topic.createdAt}'),
            SizedBox(height: 16.0),
            Text(
              topic.description,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 32.0),
            // Ajoutez d'autres widgets pour afficher les détails du topic
          ],
        ),
      ),
    );
  }
}
