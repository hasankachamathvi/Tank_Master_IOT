import 'package:flutter/material.dart';

import '../models/app_user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user, required this.onLogout});

  final AppUser user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.name.isEmpty ? 'U' : user.name[0].toUpperCase()),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.manage_accounts),
            title: Text('Account Type'),
            subtitle: Text('Standard User'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.security),
            title: Text('Security'),
            subtitle: Text('2FA disabled'),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}
