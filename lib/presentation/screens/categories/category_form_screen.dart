import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryFormScreen extends StatelessWidget {
  final String? categoryId;
  
  const CategoryFormScreen({super.key, this.categoryId});

  @override
  Widget build(BuildContext context) {
    final isEditing = categoryId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Category Form', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 8),
            Text('This screen will show category creation/editing form', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}