import 'package:flutter/material.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> dummyExpenses = [
      'Pizza - Rs. 1200',
      'Uber Ride - Rs. 800',
      'Hotel Booking - Rs. 5000',
      'Groceries - Rs. 2200',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body:
          dummyExpenses.isEmpty
              ? const Center(
                child: Text('No expenses yet.', style: TextStyle(fontSize: 18)),
              )
              : ListView.builder(
                itemCount: dummyExpenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(dummyExpenses[index]),
                    onTap: () {
                      // TODO: Navigate to expense detail screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tapped on ${dummyExpenses[index]}'),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Expense screen or show bottom sheet/dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Expense clicked')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
