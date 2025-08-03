import 'package:flutter/material.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> dummyGroups = [
      'Trip to Murree',
      'Roommates',
      'Birthday Party',
      'Office Project',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body:
          dummyGroups.isEmpty
              ? const Center(
                child: Text('No groups yet.', style: TextStyle(fontSize: 18)),
              )
              : ListView.builder(
                itemCount: dummyGroups.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.group),
                    title: Text(dummyGroups[index]),
                    onTap: () {
                      // TODO: Navigate to group detail screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tapped on ${dummyGroups[index]}'),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Create Group screen or show bottom sheet/dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Create Group clicked')));
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }
}
