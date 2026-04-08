import 'package:flutter/material.dart';

import '../models/app_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user, required this.onLogout});

  final AppUser user;
  final VoidCallback onLogout;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _pushAlerts = true;
  bool _emailSummary = false;
  bool _autoPump = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(widget.user.name.isEmpty ? 'U' : widget.user.name[0].toUpperCase()),
            ),
            title: Text(widget.user.name),
            subtitle: Text(widget.user.email),
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
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Tank Capacity'),
            subtitle: Text('1000 L (configured)'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Push Alerts'),
                subtitle: const Text('Get instant low/high level notifications'),
                value: _pushAlerts,
                onChanged: (value) {
                  setState(() {
                    _pushAlerts = value;
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Email Summary'),
                subtitle: const Text('Receive weekly usage reports by email'),
                value: _emailSummary,
                onChanged: (value) {
                  setState(() {
                    _emailSummary = value;
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Auto Pump Mode'),
                subtitle: const Text('Automatically run pump at low levels'),
                value: _autoPump,
                onChanged: (value) {
                  setState(() {
                    _autoPump = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}
