import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionManagementScreen extends StatelessWidget {
  const SessionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Session / Device Management")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('sessions')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No active sessions found."));
          }

          final sessions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final data = sessions[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['device'] ?? 'Unknown Device'),
                subtitle: Text(data['loginTime'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('sessions')
                        .doc(sessions[index].id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
