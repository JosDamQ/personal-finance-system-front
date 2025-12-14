import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_router.dart';
import '../../widgets/common/app_drawer.dart';

class CreditCardListScreen extends StatelessWidget {
  const CreditCardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go(AppRouter.creditCardForm),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Credit Card Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 8),
            Text('This screen will show credit card management functionality', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}