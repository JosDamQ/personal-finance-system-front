import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreditCardFormScreen extends StatelessWidget {
  final String? cardId;
  
  const CreditCardFormScreen({super.key, this.cardId});

  @override
  Widget build(BuildContext context) {
    final isEditing = cardId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Credit Card' : 'Add Credit Card'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Credit Card Form', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 8),
            Text('This screen will show credit card creation/editing form', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}