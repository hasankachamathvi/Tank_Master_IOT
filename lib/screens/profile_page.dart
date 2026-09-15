import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../widgets/mobile_ui.dart';

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
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _editProfile() async {
    final result = await showModalBottomSheet<AppUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileSheet(user: _user),
    );
    if (result != null) {
      setState(() => _user = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = Color(_user.avatarColor);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const PageIntro(
            title: 'Your home.\nYour preferences.',
            subtitle: 'A personal space for your water setup.',
            icon: Icons.person_outline_rounded,
            color: AppColors.mint,
            eyebrow: 'MY PROFILE'),
        const SizedBox(height: 20),
        _buildHeader(avatarColor),
        const SizedBox(height: 16),
        const Text('Account Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildAccountInfo(),
        const SizedBox(height: 16),
        const Text('Preview preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _buildPreferences(),
        const SizedBox(height: 20),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildHeader(Color avatarColor) {
    return Card(
      elevation: 0,
      color: const Color(0xFFE9F6F1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [avatarColor, avatarColor.withValues(alpha: 0.7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: avatarColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _user.name.isEmpty ? 'U' : _user.name[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _editProfile,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF329B7F),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child:
                          const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_user.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(_user.email,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            if (_user.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_user.phone,
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _ProfileBadge(
                    icon: Icons.location_on,
                    text: _user.location.isEmpty ? 'Not set' : _user.location),
                const SizedBox(width: 8),
                _ProfileBadge(
                    icon: Icons.water_drop,
                    text: '${_user.tankCapacity.toStringAsFixed(0)} L'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _AccountTile(
              icon: Icons.manage_accounts,
              title: 'Account Type',
              subtitle: 'Standard User'),
          const Divider(height: 1, indent: 56),
          _AccountTile(
              icon: Icons.security,
              title: 'Security',
              subtitle: '2FA disabled'),
          const Divider(height: 1, indent: 56),
          _AccountTile(
            icon: Icons.analytics,
            title: 'Tank Capacity',
            subtitle: '${_user.tankCapacity.toStringAsFixed(0)} L (configured)',
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Push Alerts'),
            subtitle:
                const Text('Preview low/high level alerts on this device'),
            value: _pushAlerts,
            activeTrackColor: const Color(0xFF329B7F),
            onChanged: (v) => setState(() => _pushAlerts = v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Email Summary'),
            subtitle: const Text('Preview weekly report preference'),
            value: _emailSummary,
            activeTrackColor: const Color(0xFF329B7F),
            onChanged: (v) => setState(() => _emailSummary = v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Auto Pump Mode'),
            subtitle: const Text('Preview automatic pump preference'),
            value: _autoPump,
            activeTrackColor: const Color(0xFF329B7F),
            onChanged: (v) => setState(() => _autoPump = v),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.red.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 2)
        ],
      ),
      child: FilledButton.icon(
        onPressed: widget.onLogout,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFFE53935),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Log Out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F5EE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF329B7F)),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F5EE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF329B7F)),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF329B7F))),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.user});
  final AppUser user;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  int _avatarColor = 0xFF329B7F;

  static const _colorOptions = [
    0xFF329B7F,
    0xFF00897B,
    0xFF7B1FA2,
    0xFFE64A19,
    0xFF2E7D32,
    0xFFC2185B
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _locationController = TextEditingController(text: widget.user.location);
    _capacityController = TextEditingController(
        text: widget.user.tankCapacity.toStringAsFixed(0));
    _avatarColor = widget.user.avatarColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(widget.user.copyWith(
      name: _nameController.text.trim().isEmpty
          ? widget.user.name
          : _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      tankCapacity:
          double.tryParse(_capacityController.text) ?? widget.user.tankCapacity,
      avatarColor: _avatarColor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profile',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16364B)),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _buildField(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 14),
            _buildField(_phoneController, 'Phone Number', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            _buildField(
                _locationController, 'Location', Icons.location_on_outlined),
            const SizedBox(height: 14),
            _buildField(_capacityController, 'Tank Capacity (L)',
                Icons.water_drop_outlined,
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const Text('Avatar Color',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 12,
              children: _colorOptions.map((color) {
                final isSelected = _avatarColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _avatarColor = color),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(color),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: Color(color).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2)
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                backgroundColor: const Color(0xFF329B7F),
              ),
              child: const Text('Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
