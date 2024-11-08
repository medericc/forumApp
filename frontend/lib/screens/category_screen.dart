import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_services.dart';

class CategoryListScreen extends StatefulWidget {
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = ApiService().getCategories(); // Assurez-vous que vous avez une méthode getCategories() dans ApiService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des catégories'),
      ),
      body: FutureBuilder<List<Category>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Category> categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index].name),
                );
              },
            );
          } else {
            return Center(child: Text('Aucune catégorie trouvée'));
          }
        },
      ),
    );
  }
}
