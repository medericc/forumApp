// lib/widgets/category_list.dart

import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final void Function(int) onCategorySelected;

  CategoryList({
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          title: Text(category.name),
          onTap: () => onCategorySelected(category.id),
        );
      },
    );
  }
}
