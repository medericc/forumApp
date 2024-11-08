// lib/widgets/topic_list.dart

import 'package:flutter/material.dart';
import '../models/topic.dart';

class TopicList extends StatelessWidget {
  final List<Topic> topics;
  final void Function(int) onTopicSelected;

  TopicList({
    required this.topics,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return ListTile(
          title: Text(topic.title),
          subtitle: Text(topic.description),
          onTap: () => onTopicSelected(topic.id),
        );
      },
    );
  }
}
